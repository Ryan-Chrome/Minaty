class ChangeDatatypeRoomIdOfGeneralMessages < ActiveRecord::Migration[6.0]
  def change
    change_column :general_messages, :room_id, :string
  end
end
