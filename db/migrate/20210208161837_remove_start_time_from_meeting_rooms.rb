class RemoveStartTimeFromMeetingRooms < ActiveRecord::Migration[6.0]
  def change
    remove_column :meeting_rooms, :start_time, :string
    remove_column :meeting_rooms, :end_time, :string
  end
end
