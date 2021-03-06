class GeneralMessage < ApplicationRecord

  # GeneralMessageモデル　バリデーション
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 400 }

  # User関連アソシエーション
  belongs_to :user

  # GeneralMessageRelation関連アソシエーション
  has_many :general_message_relations, dependent: :delete_all
  has_many :receive_users, through: :general_message_relations, source: :user
end
