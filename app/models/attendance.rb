class Attendance < ApplicationRecord
    # Attendanceモデル バリデーション
    validates :user_id, presence: true
    validates :work_on, presence: true, uniqueness: { scope: :user_id }
    validates :arrived_at, presence: true
    validate :work_on_validate

    # User関連アソシエーション
    belongs_to :user

    def work_on_validate
        if work_on.present?
            unless work_on == Date.today
                errors.add(:work_on, "本日以外の日付は登録できません")
            end
        end
    end
    
end
