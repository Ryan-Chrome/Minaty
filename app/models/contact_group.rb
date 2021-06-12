class ContactGroup < ApplicationRecord

  # ContactGroupモデル　バリデーション
  validates :user_id, presence: true
  validates :name, presence: true, length: { maximum: 10 }

  # User関連アソシエーション
  belongs_to :user

  # ContactGroupRelation関連アソシエーション
  has_many :contact_group_relations, dependent: :delete_all
  has_many :users, through: :contact_group_relations
end
