class GeneralMessageBroadcastJob < ApplicationJob
  queue_as :default

  def perform(general_message_relation)
    ActionCable.server.broadcast "general_channel_#{general_message_relation.receive_user.public_uid}", 
      general_message: render_general_message(general_message_relation),
      individual_message: render_individual_message(general_message_relation.general_message),
      room_message: render_room_message(general_message_relation.general_message)
    # Do something later
  end

  private

    def render_general_message(general_message_relation)
      ApplicationController.renderer.render partial: 'general_messages/general_message', locals: { message_relation: general_message_relation }
    end

    def render_individual_message(message)
      ApplicationController.renderer.render partial: 'general_messages/individual_other_message', locals: { message: message }
    end

    def render_room_message(message)
      ApplicationController.renderer.render partial: 'room_messages/outside_add_room_message', locals: { message: message }
    end

end
