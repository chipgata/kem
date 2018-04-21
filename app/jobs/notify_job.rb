class NotifyJob < ApplicationJob
  queue_as :default

  def perform
    endpoint_ids = $redis.smembers "fail_check_endpoints"
    @endpoints = Endpoint.find(endpoint_ids)
    @checks_info = {}
    @endpoints.each do |e|
      check_info = JSON.load $redis.get "endpoint_check:" + e.id.to_s
      @checks_info[e.id] = check_info
      OttSentJob.perform_later(e, check_info)
    end
    ActionCable.server.broadcast "endpoint_check", { "endpoints" => @endpoints, "checks_info" => @checks_info }
  end

  private
  def send_to_OTT
    
  end
end
