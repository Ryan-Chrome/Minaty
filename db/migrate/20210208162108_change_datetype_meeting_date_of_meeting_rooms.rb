class ChangeDatetypeMeetingDateOfMeetingRooms < ActiveRecord::Migration[6.0]
  def change
    change_column :meeting_rooms, :meeting_date, :datetime
  end
end
