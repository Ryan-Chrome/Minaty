class RoomMessageBroadcastJob < ApplicationJob
  queue_as :default

  def perform(room_message)
    ActionCable.server.broadcast "room_channel_#{room_message.meeting_room.public_uid}",
      room_message: render_room_message(room_message)
    # Do something later
  end

  private

  def render_room_message(room_message)
    ApplicationController.renderer.render partial: "room_messages/add_room_message", locals: { message: room_message }
  end
end
