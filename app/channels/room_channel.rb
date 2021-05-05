class RoomChannel < ApplicationCable::Channel
  def subscribed
    # stream_from "some_channel"
    room = MeetingRoom.find_by(public_uid: params["room"])
    if current_user.meeting_rooms.include?(room)
      stream_from "room_channel_#{params['room']}"
    end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

end
