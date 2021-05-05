class CreateRoomMessages < ActiveRecord::Migration[6.0]
  def change
    create_table :room_messages do |t|
      t.references :user, null: false, foreign_key: true
      t.references :meeting_room, null: false, foreign_key: true
      t.text :content

      t.timestamps
    end
  end
end
