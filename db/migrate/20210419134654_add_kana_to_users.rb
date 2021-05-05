class AddKanaToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :kana, :string
  end
end
