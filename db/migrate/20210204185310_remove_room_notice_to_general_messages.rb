class RemoveRoomNoticeToGeneralMessages < ActiveRecord::Migration[6.0]
  def change
    remove_column :general_messages, :room_notice
  end
end
