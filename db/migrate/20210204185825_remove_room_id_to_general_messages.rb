class RemoveRoomIdToGeneralMessages < ActiveRecord::Migration[6.0]
  def change
    add_column :general_messages, :room_id, :integer
  end
end
