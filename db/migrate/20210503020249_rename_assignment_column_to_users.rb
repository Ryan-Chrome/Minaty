class RenameAssignmentColumnToUsers < ActiveRecord::Migration[6.0]
  def change
    rename_column :users, :assignment, :department
  end
end
