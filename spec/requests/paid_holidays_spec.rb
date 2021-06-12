require "rails_helper"

RSpec.describe "PaidHolidays", type: :request do
  let!(:dept) { create(:human_resources_dept) }
  let!(:user) { create(:user, department_id: dept.id) }

  # 有給新規作成フォーム
  describe "GET #new" do
    subject { get new_paid_holiday_path }

    context "ログイン済" do
      before { sign_in user }

      it "リクエスト成功" do
        subject
        expect(response.status).to eq 200
      end
    end

    context "未ログイン" do
      it "リクエスト成功" do
        subject
        expect(response.status).to eq 302
      end

      it "ログインページへリダイレクト" do
        subject
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  # 新規作成
  describe "POST #create" do
    let(:valid_params) { { "paid_holiday" => { "holiday_on" => Date.today, "reason" => "私用" } } }
    let(:invalid_params) { { "paid_holiday" => { "holiday_on" => Date.today, "reason" => "" } } }

    context "ログイン済" do
      before { sign_in user }

      context "パラメータが正の場合" do
        subject { post paid_holidays_path, params: valid_params }

        it "リクエスト成功" do
          subject
          expect(response.status).to eq 302
        end

        it "有給休暇申請成功" do
          expect do
            subject
          end.to change { PaidHoliday.count }.by(1)
        end

        it "ダッシュボードへリダイレクト" do
          subject
          expect(response).to redirect_to user_path(user.public_uid)
        end
      end

      context "パラメータが不正な場合" do
        subject { post paid_holidays_path, params: invalid_params }

        it "リクエスト成功" do
          subject
          expect(response.status).to eq 200
        end

        it "有給休暇申請失敗" do
          expect do
            subject
          end.to change { PaidHoliday.count }.by(0)
        end

        it "フォームに'field_with_errors'が存在すること" do
          subject
          expect(response.body).to include "field_with_errors"
        end
      end

      context "申請済の日付を登録しようと場合" do
        let!(:paid_holiday_create) { user.paid_holidays.create(holiday_on: Date.today, reason: "私用") }
        subject { post paid_holidays_path, params: valid_params }

        it "リクエスト成功" do
          subject
          expect(response.status).to eq 200
        end

        it "有給休暇申請失敗" do
          expect do
            subject
          end.to change { PaidHoliday.count }.by(0)
        end

        it "フォームに'field_with_errors'が存在すること" do
          subject
          expect(response.body).to include "field_with_errors"
        end
      end
    end

    context "未ログイン" do
      subject { post paid_holidays_path, params: valid_params }

      it "リクエスト成功" do
        subject
        expect(response.status).to eq 302
      end

      it "有給休暇申請失敗" do
        expect do
          subject
        end.to change { PaidHoliday.count }.by(0)
      end

      it "ログインページへリダイレクト" do
        subject
        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end
