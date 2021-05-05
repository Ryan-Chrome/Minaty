class AddUniqueIndexToAttendances < ActiveRecord::Migration[6.0]
  def change
    add_index :attendances, [:user_id, :work_on], unique: true
  end
end
