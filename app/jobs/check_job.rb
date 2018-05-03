class CheckJob < ApplicationJob
  queue_as :default

  def perform(*args)
    @last_msg = ""
    @endpoints = get_endpoint_from_redis
    @endpoints.each do |endpoint|
      check_process(endpoint)
    end
    
  end
  
  def ping_check(path, port, timeout, extend={})
    begin
      Timeout.timeout(timeout) do 
          s = TCPSocket.new(path, port)
          s.close 
          @last_msg = "Ping OK"
          true
      end
      rescue  => e
        @last_msg = e
        false
    end
  end

  def http_check(path, port, timeout, extend={})
    begin
      conn = Faraday.new 'http://' + path + ':' + port.to_s do |conn|
        conn.options[:open_timeout] = timeout
        conn.options[:timeout] = timeout
        conn.adapter Faraday.default_adapter
      end

      response = conn.get('/')
      if response.status == extend['http_code_expect']
        @last_msg = "HTTP OK. Expected #{extend['http_code_expect']}."
        true
      else
        @last_msg = "HTTP FAIL. Expected #{extend['http_code_expect']}. Current #{response.status}."
        false
      end

      rescue  => e
        @last_msg = e
        false
    end
  end

  def https_check(path, port, timeout, extend={})
    begin
      conn = Faraday.new 'https://' + path + ':' + port.to_s do |conn|
        conn.options[:open_timeout] = timeout
        conn.options[:timeout] = timeout
        conn.adapter Faraday.default_adapter
      end

      response = conn.get('/')
      if response.status == extend['http_code_expect']
        @last_msg = "HTTPS OK. Expected #{extend['http_code_expect']}"
        true
      else
        @last_msg = "HTTPS FAIL. Expected #{extend['http_code_expect']}. Current #{response.status}"
        false
      end

      rescue  => e
        @last_msg = e
        false
    end
  end

  def ssl_check(path, port, timeout, extend={})
    valid, error, cert = SSLTest.test "https://" + path + ':' + port.to_s, open_timeout: timeout, read_timeout: timeout
    if valid
      @last_msg = "SSL OK"
      true
    else
      @last_msg = error
      false
    end
  end

  def check_process(endpoint)
    check_info = get_check_info(endpoint["id"])
    check_time = Time.now;
    if !check_info["last_check"] or (check_time - check_info["last_check"].to_datetime) >= endpoint["check_interval"]
      if send(endpoint["check_protocol"] + '_check', endpoint["path"], endpoint["port"], endpoint["response_timeout"], endpoint["check_extend"])
        if check_info["check_status"] == 'FAIL' or check_info["check_status"] == 'UNKNOW'
          check_info['healthy_count'] += 1
        end
        if check_info['healthy_count'].to_i >= endpoint["healthy_threshold"].to_i
          check_info["check_status"] = 'OK'
          check_info['unhealthy_count'] = 0
          check_info['is_notified'] = 0
        end
        if check_info["check_status"] == 'OK' and exist_endpoint_store(endpoint)
          e = Endpoint.find(endpoint['id'])
          OttSentJob.perform_later(e, check_info)
          fail_endpoint_remove(endpoint)
        end
      else
        if check_info["check_status"] == 'OK'
          check_info['unhealthy_count'] += 1
        end
        if check_info['unhealthy_count'].to_i >= endpoint["unhealthy_threshold"].to_i
          check_info["check_status"] = 'FAIL'
          check_info['healthy_count'] = 0
        end
        if check_info["check_status"] == 'FAIL' and !exist_endpoint_store(endpoint)
          fail_endpoint_store(endpoint)
        end
      end
      check_info['last_check'] = check_time
      check_info['next_check'] = check_time + endpoint["check_interval"]
      check_info['last_msg'] = @last_msg
      set_check_info(endpoint["id"], check_info)
      NotifyJob.perform_now
    end
  end

  def get_check_info(endpoint_id)
    check_info = $redis.get "endpoint_check:" + endpoint_id.to_s
    if check_info.nil?
      check_info = { "endpoint_id" => endpoint_id, "check_status"=>'OK', "unhealthy_count" => 0, "healthy_count" => 0, "last_msg" => @last_msg, "is_notified" => 0 }.to_json
      set_check_info(endpoint_id, check_info)
    end
    JSON.load check_info
  end

  def exist_endpoint_store(endpoint)
    $redis.sismember "fail_check_endpoints", endpoint['id']
  end

  def fail_endpoint_store(endpoint)
    $redis.sadd "fail_check_endpoints", endpoint['id']
  end

  def fail_endpoint_remove(endpoint)
    $redis.srem "fail_check_endpoints", endpoint['id']
  end

  def get_endpoint_from_redis
    begin
      endpoints = $redis.get "endpoints"
  
      if endpoints.nil?
        endpoints = Endpoint.all.to_json
        $redis.set "endpoints", endpoints
      end
      endpoints = JSON.load endpoints
    rescue => error
      puts error.inspect
      endpoints = Endpoint.all
    end
    endpoints
  end

  private :ping_check, :http_check, :https_check, :ssl_check, :check_process, :get_check_info, :get_endpoint_from_redis, :fail_endpoint_store, :fail_endpoint_remove

end
