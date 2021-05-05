class RemoveHolidayFromAttendances < ActiveRecord::Migration[6.0]
  def change
    remove_column :attendances, :holiday, :boolean
  end
end
