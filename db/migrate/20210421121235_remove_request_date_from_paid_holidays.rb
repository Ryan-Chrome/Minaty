class RemoveRequestDateFromPaidHolidays < ActiveRecord::Migration[6.0]
  def change
    remove_column :paid_holidays, :request_date, :datetime
  end
end
