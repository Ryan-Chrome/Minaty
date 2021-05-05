class AddColumnPublicUidToMeetingRooms < ActiveRecord::Migration[6.0]
  def change
    add_column :meeting_rooms, :public_uid, :string
    add_index  :meeting_rooms, :public_uid, unique: true
  end
end
