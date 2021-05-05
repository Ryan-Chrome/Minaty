class AddWorkOnToAttendances < ActiveRecord::Migration[6.0]
  def change
    add_column :attendances, :work_on, :date, null: false
  end
end
