require 'rails_helper'

RSpec.describe "PaidHolidays", type: :request do

    let!(:user){ create(:user) }
    let(:valid_params){ {"paid_holiday"=>{"holiday_on"=> Date.today, "reason"=>"私用"}} }
    let(:invalid_params){ {"paid_holiday"=>{"holiday_on"=> Date.today, "reason"=>""}} }
    let(:paid_holiday_create){ user.paid_holidays.create(holiday_on: Date.today, reason: "私用") }

    # 新規作成
    describe "POST #create" do
        # ログイン済
        context "user is logged in" do
            before do
                sign_in user
            end

            context "Request" do
                # 成功
                it "Success" do
                    post paid_holidays_path,  params: valid_params
                    expect(response.status).to eq 302
                    expect(response).to redirect_to management_path(user.public_uid)
                end

                # 不正な値
                it "invalid params" do
                    post paid_holidays_path, params: invalid_params
                    expect(response.status).to eq 200
                    expect(response.body).to match "有給休暇申請"
                end

                # 作成済の日付をパラメータに含めて送信した場合
                it "same date" do
                    paid_holiday_create
                    post paid_holidays_path, params: valid_params
                    expect(response.status).to eq 200
                    expect(response.body).to match "有給休暇申請"
                end
            end

            context "Create" do
                #成功
                it "Success" do
                    expect do
                        post paid_holidays_path, params: valid_params
                    end.to change{ PaidHoliday.count }.by(1)
                end

                # 不正な値
                it "invalid params" do
                    expect do
                        post paid_holidays_path, params: invalid_params
                    end.to change{ PaidHoliday.count }.by(0)
                end

                # 作成済の日付をパラメータに含めて送信した場合
                it "same date" do
                    paid_holiday_create
                    expect do
                        post paid_holidays_path, params: valid_params
                    end.to change{ PaidHoliday.count }.by(0)
                end
            end
        end
    end

end
