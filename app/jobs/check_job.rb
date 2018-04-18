class CheckJob < ApplicationJob
  queue_as :default

  def perform(*args)
    @endpoints = Endpoint.all
    @endpoints.each do |endpoint|
      check_process(endpoint)
    end
    
    TestJob.perform_now @endpoints
  end
  
  def ping_check(path, port, timeout)
    begin
      Timeout.timeout(timeout) do 
          s = TCPSocket.new(path, port)
          s.close 
          true
      end

      rescue Errno::ECONNREFUSED => e
          logger.debug e
          true
      rescue  => e
          logger.debug e
          false
    end
  end

  def http_check(path, port, timeout)
  end

  def https_check(path, port, timeout)
  end

  def ssl_check(path, port, timeout)
  end

  def check_process(endpoint)
    check_info = CheckInfo.find(endpoint.id)
    check_time = Time.now;
    if !endpoint.last_check or (check_time - endpoint.last_check) >= endpoint.check_interval
      if send(endpoint.check_protocol + '_check', endpoint.path, endpoint.port, endpoint.response_timeout) == true
        if endpoint.check_status == 'FAIL' or endpoint.check_status == 'UNKNOW'
          check_info.healthy_count += 1
        end
        if check_info.healthy_count >= endpoint.healthy_threshold
          endpoint.check_status = 'OK'
          check_info.unhealthy_count = 0
        end
      else
        if endpoint.check_status == 'OK'
          check_info.unhealthy_count += 1
        end
        if check_info.unhealthy_count >= endpoint.unhealthy_threshold
          endpoint.check_status = 'FAIL'
          check_info.healthy_count = 0
        end
      end
      endpoint.last_check = check_time
      endpoint.next_check = check_time + endpoint.check_interval
      endpoint.save
      check_info.save
    end
  end

  private :ping_check, :http_check, :https_check, :ssl_check, :check_process

end
