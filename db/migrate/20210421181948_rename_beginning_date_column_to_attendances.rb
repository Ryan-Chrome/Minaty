class RenameBeginningDateColumnToAttendances < ActiveRecord::Migration[6.0]
  def change
    rename_column :attendances, :beginning_date, :arrived_at
    rename_column :attendances, :finish_date, :left_at
  end
end
