require 'rails_helper'

RSpec.describe "Attendances", type: :request do

    let!(:user){ create(:user) }
    
    # 出勤レコード新規作成
    describe "POST #create" do
        # ログイン済ユーザー
        context "user is logged in" do
            before do
                sign_in user
            end

            context "Request" do
                # 成功
                it "Success" do
                    post attendances_path, xhr: true
                    expect(response.status).to eq 200
                    expect(response.body).to match "出勤時間"
                end

                # 作成済の場合
                context "Created" do
                    let!(:attendance){ create(:attendance, user_id: user.id) }
                    it "Error" do
                        post attendances_path, xhr: true
                        expect(response.status).to eq 200
                        expect(response).to redirect_to root_path
                    end
                end
            end

            context "Create" do
                # 新規作成成功
                it "Success" do
                    expect do
                        post attendances_path, xhr: true
                    end.to change{ Attendance.count }.by(1)
                end

                # 同じ日付で作成されないこと
                context "Created" do
                    let!(:attendance){ create(:attendance, user_id: user.id) }
                    it "Error" do
                        expect do
                            post attendances_path, xhr: true
                        end.to change{ Attendance.count }.by(0)
                    end
                end
            end
        end
    end

    # 退勤打刻
    describe "PATCH #update" do
        # ログイン済ユーザー
        context "user is logged in" do
            let!(:attendance){ user.attendances.create(work_on: Date.today, arrived_at: DateTime.now) }
            before do
                sign_in user
            end

            context "Request" do
                # 成功
                it "Success" do
                    patch attendance_path(attendance.id), xhr: true
                    expect(response.status).to eq 200
                    expect(response.body).to match "退勤時間"
                end
            end

            context "Update" do
                # 成功
                it "Success" do
                    patch attendance_path(attendance.id), xhr: true
                    expect(attendance.reload.left_at).to be_present
                end
            end
        end
    end

end
