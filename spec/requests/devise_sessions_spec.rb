require "rails_helper"

RSpec.describe "UserLogin", type: :request do
  let!(:dept) { create(:human_resources_dept) }
  let!(:user) { create(:user, department_id: dept.id) }
  let(:valid_params) { attributes_for(:user) }
  let(:invalid_params) { attributes_for(:user, email: "") }

  # ログイン画面
  describe "GET #new" do
    subject { get new_user_session_path }
    context "ログイン済" do
      before { sign_in user }

      it "リクエスト成功" do
        subject
        expect(response.status).to eq 302
      end

      it "root_pathへリダイレクト" do
        subject
        expect(response).to redirect_to root_path
      end
    end

    context "未ログイン" do
      it "リクエスト成功" do
        subject
        expect(response.status).to eq 200
      end

      it "ログイン画面が表示されること" do
        subject
        expect(response.body).to include "loginContent" 
      end
    end
  end

  # ユーザーログイン
  describe "POST #create" do
    context "ログイン済" do
      before { sign_in user }

      subject {
        post user_session_path,
             params: { user: valid_params }
      }

      it "リクエスト成功" do
        subject
        expect(response.status).to eq 302
      end

      it "root_pathへリダイレクト" do
        subject
        expect(response).to redirect_to root_path
      end
    end

    context "未ログイン" do
      context "パラメータが正の場合" do
        subject {
          post user_session_path,
               params: { user: valid_params }
        }

        it "リクエスト成功" do
          subject
          expect(response.status).to eq 302
        end

        it "root_pathへリダイレクト" do
          subject
          expect(response).to redirect_to root_path
        end

        it "レスポンスにユーザー名が含まれること" do
          subject
          expect(response.body).to include valid_params[:name]
        end
      end

      context "パラメータが不正な場合" do
        subject {
          post user_session_path,
               params: { user: invalid_params }
        }

        it "リクエスト成功" do
          subject
          expect(response.status).to eq 200
        end

        it "エラーメッセージ表示" do
          subject
          expect(response.body).to include "Eメールまたはパスワードが違います。"
        end
      end
    end
  end

  # ユーザーログアウト
  describe "DELETE #destroy" do
    context "ログイン済" do
      before { sign_in user }

      subject { delete destroy_user_session_path  }

      it "リクエスト成功" do
        subject
        expect(response.status).to eq 302
      end

      it "root_pathへリダイレクト" do
        subject
        expect(response).to redirect_to root_path
      end
    end

    context "未ログイン" do
      subject { delete destroy_user_session_path }

      it "リクエスト成功" do
        subject
        expect(response.status).to eq 302
      end

      it "root_pathへリダイレクト" do
        subject
        expect(response).to redirect_to root_path
      end
    end
  end
end
