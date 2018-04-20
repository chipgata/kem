class WelcomeController < ApplicationController
  def index
    endpoint_ids = $redis.smembers "fail_check_endpoints"
    @endpoints = Endpoint.find(endpoint_ids)
    puts @endpoints
  end
end
