class RoomMessage < ApplicationRecord

  # RoomMessageモデル　バリデーション
  validates :user_id, presence: true
  validates :meeting_room_id, presence: true
  validates :content, presence: true, length: { maximum: 400 }

  # User関連アソシエーション
  belongs_to :user

  # MeetingRoom関連アソシエーション
  belongs_to :meeting_room

  # DBへのコミットが正常に終了したらJob呼び出し
  after_create_commit { RoomMessageBroadcastJob.perform_later self }
end
