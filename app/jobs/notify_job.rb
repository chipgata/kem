class NotifyJob < ApplicationJob
  queue_as :default

  def perform
    endpoint_ids = $redis.smembers "fail_check_endpoints"
    @endpoints = Endpoint.find(endpoint_ids)
    @checks_info = {}
    @endpoints.each do |e|
      @checks_info[e.id] = JSON.load $redis.get "endpoint_check:" + e.id.to_s
    end
    ActionCable.server.broadcast "endpoint_check", { "endpoints" => @endpoints, "checks_info" => @checks_info }
  end
end
