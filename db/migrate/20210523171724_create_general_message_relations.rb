class CreateGeneralMessageRelations < ActiveRecord::Migration[6.0]
  def change
    create_table :general_message_relations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :general_message, null: false, foreign_key: true

      t.timestamps

      t.index [:user_id, :general_message_id], unique: true, name: "index_relations_on_user_id_and_general_message_id"
    end
  end
end
