class RenameStartTimeColumnToMeetingRooms < ActiveRecord::Migration[6.0]
  def change
    rename_column :meeting_rooms, :start_time, :start_at
    rename_column :meeting_rooms, :end_time, :finish_at
  end
end
