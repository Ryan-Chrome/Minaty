class CreateGeneralMessageRelations < ActiveRecord::Migration[6.0]
  def change
    create_table :general_message_relations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :receive_user, null: false, foreign_key: { to_table: :users }
      t.references :general_message, null: false, foreign_key: true

      t.timestamps

      t.index [:receive_user_id, :general_message_id], unique: true, name: "index_general_message_user_message"
    end
  end
end
