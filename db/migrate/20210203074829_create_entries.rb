class CreateEntries < ActiveRecord::Migration[6.0]
  def change
    create_table :entries do |t|
      t.references :meeting_room, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps

      t.index [:user_id, :meeting_room_id], unique: true
    end
  end
end
