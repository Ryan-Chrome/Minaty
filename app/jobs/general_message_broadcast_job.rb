class GeneralMessageBroadcastJob < ApplicationJob
  queue_as :default

  def perform(relation)
    ActionCable.server.broadcast "general_channel_#{relation.user.public_uid}",
      general_message: render_general_message(relation.general_message),
      individual_message: render_individual_message(relation.general_message),
      room_message: render_room_message(relation.general_message),
      send_user: relation.general_message.user.name
  end

  private

  def render_general_message(message)
    ApplicationController.renderer.render partial: "general_messages/other_user_message", locals: { message: message }
  end

  def render_individual_message(message)
    ApplicationController.renderer.render partial: "general_messages/individual_other_message", locals: { message: message }
  end

  def render_room_message(message)
    ApplicationController.renderer.render partial: "room_messages/outside_add_room_message", locals: { message: message }
  end
end
