require 'rails_helper'

RSpec.describe Attendance, type: :model do
  
    let!(:user){ create(:user) }
    let(:attendance){ user.attendances.build(work_on: Date.today, arrived_at: DateTime.now) }

    # 全てのカラムが正常
    it "is valid with a work_on and arrived_at" do
      expect(attendance).to be_valid
    end

    # 日付が空の場合
    it "is invalid without a work_on" do
      attendance.work_on = ""
      expect(attendance).not_to be_valid
    end

    # 日付が今日以外の日付である場合
    it "is invalid a work_on(not today)" do
      attendance.work_on = Date.today + 1.day
      expect(attendance).not_to be_valid
    end

    # 出勤時間が空の場合
    it "is invalid without a arrived_at" do
      attendance.arrived_at = ""
      expect(attendance).not_to be_valid
    end

end
