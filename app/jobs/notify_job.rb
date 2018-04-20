class NotifyJob < ApplicationJob
  queue_as :default

  def perform
    endpoint_ids = $redis.smembers "fail_check_endpoints"
    @endpoints = Endpoint.find(endpoint_ids)
    ActionCable.server.broadcast "endpoint_check", @endpoints
  end
end
