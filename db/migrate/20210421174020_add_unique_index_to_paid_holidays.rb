class AddUniqueIndexToPaidHolidays < ActiveRecord::Migration[6.0]
  def change
    add_index :paid_holidays, [:user_id, :holiday_date], unique: true
  end
end
