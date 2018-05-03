class NotifyJob < ApplicationJob
  queue_as :default

  def perform
    endpoint_ids = $redis.smembers "fail_check_endpoints"
    @endpoints = Endpoint.find(endpoint_ids)
    @checks_info = {}
    @endpoints.each do |e|
      check_info = JSON.load $redis.get "endpoint_check:" + e.id.to_s
      @checks_info[e.id] = check_info
      if e.enable_notification and check_info['is_notified'].to_i == 0
        OttSentJob.perform_later(e, check_info)
        check_info['is_notified'] = 1
        set_check_info(e.id, check_info)
      end
    end
    ActionCable.server.broadcast "endpoint_check", { "endpoints" => @endpoints, "checks_info" => @checks_info }
  end
  
end
