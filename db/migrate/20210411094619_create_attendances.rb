class CreateAttendances < ActiveRecord::Migration[6.0]
  def change
    create_table :attendances do |t|
      t.datetime :beginning_date
      t.datetime :finish_date
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
