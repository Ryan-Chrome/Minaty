class CreateContactGroupRelations < ActiveRecord::Migration[6.0]
  def change
    create_table :contact_group_relations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :contact_group, null: false, foreign_key: true

      t.timestamps
      t.index [:user_id, :contact_group_id], unique: true
    end
  end
end
