class Attendance < ApplicationRecord
  # Attendanceモデル バリデーション
  validates :user_id, presence: true
  validates :work_on, presence: true, uniqueness: { scope: :user_id }
  validates :arrived_at, presence: true
  validate :work_on_validate
  validate :arrived_at_validate
  validate :left_at_validate

  # User関連アソシエーション
  belongs_to :user

  def work_on_validate
    if work_on.present?
      unless work_on == Date.today
        errors.add(:work_on, "本日以外の日付は登録できません")
      end
    end
  end

  def arrived_at_validate
    if arrived_at.present?
      unless Date.today == Date.parse(arrived_at.strftime("%Y/%m/%d"))
        errors.add(:arrived_at, "値が不正です")
      end
    end
  end

  def left_at_validate
    if left_at.present?
      unless Date.today == Date.parse(left_at.strftime("%Y/%m/%d"))
        errors.add(:left_at, "値が不正です")
      end
    end
  end
end
