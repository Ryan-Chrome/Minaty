class GeneralChatChannel < ApplicationCable::Channel
  def subscribed
    # stream_from "some_channel"
    stream_from "general_channel_#{current_user.public_uid}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

end
