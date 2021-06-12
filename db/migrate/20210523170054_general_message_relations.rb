class GeneralMessageRelations < ActiveRecord::Migration[6.0]
  def change
    drop_table :general_message_relations
  end
end
