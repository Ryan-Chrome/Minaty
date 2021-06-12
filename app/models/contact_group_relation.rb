class ContactGroupRelation < ApplicationRecord

  # ContactGroupRelationモデル　バリデーション
  validates :user_id, presence: true
  validates :contact_group_id, presence: true, uniqueness: { scope: :user_id }

  # User関連アソシエーション
  belongs_to :user

  # ContactGroup関連アソシエーション
  belongs_to :contact_group
end
