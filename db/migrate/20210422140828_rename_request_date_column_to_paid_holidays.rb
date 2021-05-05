class RenameRequestDateColumnToPaidHolidays < ActiveRecord::Migration[6.0]
  def change
    rename_column :paid_holidays, :holiday_date, :holiday_on
  end
end
