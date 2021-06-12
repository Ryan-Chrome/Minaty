class Entry < ApplicationRecord

  # Entryモデル　バリデーション
  validates :user_id, presence: true
  validates :meeting_room_id, presence: true, uniqueness: { scope: :user_id }

  # User関連アソシエーション
  belongs_to :user

  # MeetingRoom関連アソシエーション
  belongs_to :meeting_room
end
