require 'rails_helper'

# スケジュールモデル関連テスト
RSpec.describe Schedule, type: :model do

    let!(:user){ create(:user) }
    let(:schedule){ FactoryBot.build(:schedule, user_id: user.id) }

    # 全てのカラムが正の場合
    it "is valid with a name and start_time and end_time and schedule_date and user_id" do
        expect(schedule).to be_valid
    end

    # 名前が空の場合
    it "is invalid without a name" do
        schedule.name = ""
        expect(schedule).not_to be_valid
    end

    # 名前が21文字以上の場合
    it "is invaid when a name is 21 characters" do
        schedule.name = "a" * 21
        expect(schedule).not_to be_valid
    end

    # 開始時刻が空の場合
    it "is invalid without a start_time" do
        schedule.start_at = ""
        expect(schedule).not_to be_valid
    end

    # 開始時刻が不正な値の場合
    it "is invalid when a start_time is incorrect" do
        schedule.start_at = "time"
        expect(schedule).not_to be_valid
    end

    # 終了時刻がからの場合
    it "is invalid without a end_time" do
        schedule.finish_at = ""
        expect(schedule).not_to be_valid
    end

    # 終了時刻が不正な値の場合
    it "is invalid when a end_time is incorrect" do
        schedule.finish_at = "time"
        expect(schedule).not_to be_valid
    end

    # 日付が空の場合
    it "is invalid without a schedule_date" do
        schedule.work_on = ""
        expect(schedule).not_to be_valid
    end

    # ユーザーIDが空の場合
    it "is invalid without a user_id" do
        schedule.user_id = ""
        expect(schedule).not_to be_valid
    end

    # 開始時刻が終了時刻より遅い場合
    it "is invalid schedule_start_end_check" do
        schedule.start_at = "15:40"
        schedule.finish_at = "10:10"
        expect(schedule).not_to be_valid
    end

    # 日付が今日より前の場合
    it "is invalid schedule_date_check" do
        schedule.work_on = Date.today - 1
        expect(schedule).not_to be_valid
    end

end