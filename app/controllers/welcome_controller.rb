class WelcomeController < ApplicationController
  def index
    endpoint_ids = $redis.smembers "fail_check_endpoints"
    @endpoints = Endpoint.find(endpoint_ids)

    @checks_info = {}
    @endpoints.each do |e|
      @checks_info[e.id] = JSON.load $redis.get "endpoint_check:" + e.id.to_s
    end
  end
end
