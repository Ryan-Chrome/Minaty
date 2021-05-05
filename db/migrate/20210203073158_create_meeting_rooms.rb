class CreateMeetingRooms < ActiveRecord::Migration[6.0]
  def change
    create_table :meeting_rooms do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.date :meeting_date
      t.string :start_time
      t.string :end_time

      t.timestamps
    end
  end
end
