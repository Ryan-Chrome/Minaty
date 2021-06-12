require "rails_helper"

RSpec.describe Schedule, type: :model do
  let!(:dept) { create(:human_resources_dept) }
  let!(:user) { create(:user, department_id: dept.id) }
  let(:schedule) { build(:schedule, user_id: user.id) }

  it "全てのカラムが正常" do
    expect(schedule).to be_valid
  end

  it "スケジュール名が空の場合" do
    schedule.name = ""
    expect(schedule).not_to be_valid
  end

  it "スケジュール名が20文字より長い場合" do
    schedule.name = "a" * 21
    expect(schedule).not_to be_valid
  end

  it "開始時刻が空の場合" do
    schedule.start_at = ""
    expect(schedule).not_to be_valid
  end

  it "開始時刻が不正な値の場合" do
    schedule.start_at = "time"
    expect(schedule).not_to be_valid
  end

  it "終了時刻が空の場合" do
    schedule.finish_at = ""
    expect(schedule).not_to be_valid
  end

  it "終了時刻が不正な値の場合" do
    schedule.finish_at = "time"
    expect(schedule).not_to be_valid
  end

  it "日付が空の場合" do
    schedule.work_on = ""
    expect(schedule).not_to be_valid
  end

  it "ユーザーIDが空の場合" do
    schedule.user_id = ""
    expect(schedule).not_to be_valid
  end

  it "開始時刻が終了時刻より遅い場合" do
    schedule.start_at = "15:40"
    schedule.finish_at = "10:10"
    expect(schedule).not_to be_valid
  end

  it "開始時刻が終了時刻が同じ場合" do
    schedule.start_at = "14:00"
    schedule.finish_at = "14:00"
    expect(schedule).not_to be_valid
  end

  it "日付が今日より前の場合" do
    schedule.work_on = Date.today - 1
    expect(schedule).not_to be_valid
  end
end
