class Schedule < ApplicationRecord

  # Scheduleモデル　バリデーション
  VALID_START_REGEX = /\A(?:2[0123]|[01]\d):[012345]0\z/i
  VALID_END_REGEX = /\A(?:2(?:[0123]:[012345]|4:0)|[01]\d:[012345])0\z/i
  validates :name, presence: true, length: { maximum: 20 }
  validates :start_at, presence: true, format: { with: VALID_START_REGEX }, length: { is: 5 }
  validates :finish_at, presence: true, format: { with: VALID_END_REGEX }, length: { is: 5 }
  validates :work_on, presence: true
  validates :user_id, presence: true
  validate :schedule_start_end_check, :schedule_date_check

  # User関連アソシエーション
  belongs_to :user

  # バリデーション　カスタムメソッド
  private

  # 開始時刻が終了時刻より遅いかチェック
  def schedule_start_end_check
    if start_at.delete("^0-9").to_i >= finish_at.delete("^0-9").to_i
      errors.add(:finish_at, "設定時刻が不正です")
    end
  end

  # 日付が今日より前かチェック
  def schedule_date_check
    if work_on.present? && work_on < Date.today
      errors.add(:work_on)
    end
  end
end
