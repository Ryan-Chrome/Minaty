class RemoveUserIdFromMeetingRoom < ActiveRecord::Migration[6.0]
  def change
    remove_reference :meeting_rooms, :user, null: false, foreign_key: true
  end
end
