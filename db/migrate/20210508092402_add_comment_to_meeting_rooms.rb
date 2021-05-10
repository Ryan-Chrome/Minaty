class AddCommentToMeetingRooms < ActiveRecord::Migration[6.0]
  def change
    add_column :meeting_rooms, :comment, :text
  end
end
