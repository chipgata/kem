class CheckNotificationsChannel < ApplicationCable::Channel
  def subscribed
    # stream_from "some_channel"
    stream_from "endpoint_check"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
