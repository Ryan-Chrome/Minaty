class AddRoomNoticeToGeneralMessages < ActiveRecord::Migration[6.0]
  def change
    add_column :general_messages, :room_notice, :boolean, default: false, null: false
  end
end
