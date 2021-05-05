class AddAssignmentToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :assignment, :string
  end
end
