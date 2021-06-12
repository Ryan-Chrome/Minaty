require "rails_helper"

RSpec.describe PaidHoliday, type: :model do
  let!(:dept) { create(:human_resources_dept) }
  let!(:user) { create(:user, department_id: dept.id) }
  let(:paid_holiday) { build(:paid_holiday, user_id: user.id) }

  it "全てのカラムが正常" do
    expect(paid_holiday).to be_valid
  end

  it "日付が空の場合" do
    paid_holiday.holiday_on = ""
    expect(paid_holiday).not_to be_valid
  end

  it "理由が空の場合" do
    paid_holiday.reason = ""
    expect(paid_holiday).not_to be_valid
  end

  it "ユーザーIDが空の場合" do
    paid_holiday.user_id = ""
    expect(paid_holiday).not_to be_valid
  end

  it "ユーザーIDと日付の組み合わせが既に存在する場合" do
    create(:paid_holiday, user_id: user.id)
    expect(paid_holiday).not_to be_valid
  end
end
