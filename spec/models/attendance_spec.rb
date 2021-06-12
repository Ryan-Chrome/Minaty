require "rails_helper"

RSpec.describe Attendance, type: :model do
  let!(:dept) { create(:human_resources_dept) }
  let!(:user) { create(:user, department_id: dept.id) }
  let(:attendance) { build(:attendance, user_id: user.id) }
  let(:registered_attendance) { create(:attendance, user_id: user.id) }

  it "全てのカラムが正常" do
    expect(attendance).to be_valid
  end

  it "日付が空の場合" do
    attendance.work_on = ""
    expect(attendance).not_to be_valid
  end

  it "出勤時間が空の場合" do
    attendance.arrived_at = ""
    expect(attendance).not_to be_valid
  end

  it "日付が今日以外の日付の場合" do
    attendance.work_on = Date.today + 1.day
    expect(attendance).not_to be_valid
  end

  it "出勤時間の日付が今日以外の日付の場合" do
    attendance.arrived_at = DateTime.now + 1.day
    expect(attendance).not_to be_valid
  end

  it "退勤時間の日付が今日以外の日付の場合" do
    attendance.left_at = DateTime.now + 1.day
    expect(attendance).not_to be_valid
  end

  it "ユーザーIDと日付の組み合わせが既に存在する場合" do
    registered_attendance
    expect(attendance).not_to be_valid
  end
end
