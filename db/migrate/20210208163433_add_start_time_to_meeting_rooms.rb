class AddStartTimeToMeetingRooms < ActiveRecord::Migration[6.0]
  def change
    add_column :meeting_rooms, :start_time, :datetime
    add_column :meeting_rooms, :end_time, :datetime

    remove_column :meeting_rooms, :meeting_date, :datetime
  end
end
