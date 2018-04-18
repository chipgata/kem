class TestJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
    #print "Hello world!"
    ActionCable.server.broadcast "endpoint_check", data: "1"
  end
end
