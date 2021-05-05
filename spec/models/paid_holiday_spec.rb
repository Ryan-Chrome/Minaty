require 'rails_helper'

RSpec.describe PaidHoliday, type: :model do
  
    let!(:user){ create(:user) }
    let(:paid_holiday){ FactoryBot.build(:paid_holiday, user_id: user.id) }

    # 全てのカラムが正常
    it "is valid with a holiday_on and reason" do
        expect(paid_holiday).to be_valid
    end

    # 日付が空の場合
    it "is invalid without a holiday_on" do
        paid_holiday.holiday_on = ""
        expect(paid_holiday).not_to be_valid
    end

    # 理由が空の場合
    it "is invalid without a reason" do
        paid_holiday.reason = ""
        expect(paid_holiday).not_to be_valid
    end

end
