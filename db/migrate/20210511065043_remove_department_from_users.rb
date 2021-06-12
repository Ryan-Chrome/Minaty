class RemoveDepartmentFromUsers < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :department, :string
  end
end
