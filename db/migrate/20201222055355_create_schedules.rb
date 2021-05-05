class CreateSchedules < ActiveRecord::Migration[6.0]
  def change
    create_table :schedules do |t|
      t.string :name
      t.string :start_time
      t.string :end_time
      t.date :schedule_date
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
