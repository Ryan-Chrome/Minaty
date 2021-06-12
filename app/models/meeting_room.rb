class MeetingRoom < ApplicationRecord
  attr_accessor :meeting_date, :date
  attr_accessor :room_entry_users

  # public_uid設定
  generate_public_uid

  def to_params
    public_uid
  end

  # MeetingRoomモデル　バリデーション
  validates :name, presence: true, length: { maximum: 15 }
  validates :comment, length: { maximum: 400 }
  validates :start_at, presence: true
  validates :finish_at, presence: true
  validates :meeting_date, presence: true
  validates :room_entry_users, presence: true
  validate :meeting_start_end_check,
           :meeting_date_check,
           :start_finish_date_check

  # Entry関連アソシエーション
  has_many :entries, dependent: :delete_all
  has_many :users, through: :entries

  # RoomMessage関連アソシエーション
  has_many :room_messages, dependent: :delete_all

  # バリデーション　カスタムメソッド
  private

  # 開始時刻が終了時刻より遅いかチェック
  def meeting_start_end_check
    if finish_at.present? && start_at.present? && start_at > finish_at
      errors.add(:finish_at, "開始時刻より終了時刻が早いです")
    elsif finish_at.present? && start_at.present? && start_at == finish_at
      errors.add(:finish_at, "開始時刻と終了時刻が同じです")
    end
  end

  # 開始時刻と終了時刻の日付が違うかチェック
  def start_finish_date_check
    if finish_at.present? && start_at.present? && finish_at.day != start_at.day
      errors.add(:finish_at, "不正な値です")
    end
  end

  # 開始時刻と終了時間の日付が今日より前かチェック
  def meeting_date_check
    if meeting_date.present? && meeting_date < Date.today
      errors.add(:meeting_date, "date_invalid")
    end
  end
end
