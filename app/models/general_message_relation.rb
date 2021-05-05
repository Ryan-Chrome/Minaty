class GeneralMessageRelation < ApplicationRecord

	# GeneralMessageRelationモデル　バリデーション
	validates :user_id, presence: true
	validates :receive_user_id, presence: true
	validates :general_message_id, presence: true

	# User関連アソシエーション
	belongs_to :user
	belongs_to :receive_user, class_name: 'User'

	# GeneralMessage関連アソシエージョン
	belongs_to :general_message

	# DBへのコミットが正常に終了したらJob呼び出し
	after_create_commit { GeneralMessageBroadcastJob.perform_later self }

end
