class CreatePaidHolidays < ActiveRecord::Migration[6.0]
  def change
    create_table :paid_holidays do |t|
      t.datetime :request_date
      t.date :holiday_date
      t.text :reason
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
