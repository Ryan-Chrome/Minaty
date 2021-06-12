class GeneralMessageRelation < ApplicationRecord

  # GeneralMessageRelationモデル　バリデーション
  validates :user_id, presence: true
  validates :general_message_id, presence: true, uniqueness: { scope: :user_id }

  # User関連アソシエーション
  belongs_to :user
  belongs_to :general_message

  # DBへのコミットが正常に終了したらJob呼び出し
  after_create_commit { GeneralMessageBroadcastJob.perform_later self }
end
