class RenameStartTimeColumnToSchedules < ActiveRecord::Migration[6.0]
  def change
    rename_column :schedules, :start_time, :start_at
    rename_column :schedules, :end_time, :finish_at
    rename_column :schedules, :schedule_date, :work_on
  end
end
