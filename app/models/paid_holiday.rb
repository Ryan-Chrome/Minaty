class PaidHoliday < ApplicationRecord

  # User関連アソシエーション
  belongs_to :user

  # PaidHolidayモデル バリデーション
  validates :holiday_on, presence: true, uniqueness: { scope: :user_id }
  validates :reason, presence: true
  validates :user_id, presence: true

end
