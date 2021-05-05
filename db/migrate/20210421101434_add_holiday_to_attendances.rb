class AddHolidayToAttendances < ActiveRecord::Migration[6.0]
  def change
    add_column :attendances, :holiday, :boolean, default: false
  end
end
