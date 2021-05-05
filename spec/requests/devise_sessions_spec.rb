require 'rails_helper'

RSpec.describe "UserLogin", type: :request do

    let!(:user){ create(:user) }
    let(:user_params){ attributes_for(:user) }
    let(:invalid_user_params){ attributes_for(:user, email: "") }

    # ログイン画面
    describe "GET #new" do
        # ログインしていないユーザー
        context "user is not logged in" do
            context "Request" do
                # レスポンス正常
                it "Success" do
                    get new_user_session_path
                    expect(response.status).to eq 200
                end
            end
        end

        # ログイン済みユーザー
        context "user is logged in" do
            before do
                sign_in user
            end

            context "Request" do
                # ログイン画面にアクセスしたらホーム画面にリダイレクトされること
                it "Redirect from login scrren to home screen" do
                    get new_user_session_path
                    expect(response.status).to eq 302
                    expect(response).to redirect_to root_path
                end
            end
        end
    end

    # ユーザーログイン
    describe "POST #create" do
        # 有効なパラメータを渡された場合
        context "If the parameters are valid" do
            it "request success" do
                post user_session_path, params: { user: user_params }
                expect(response.status).to eq 302
            end
        end

        # 無効なパラメータを渡された場合
        context "If the parameters are invalid" do
            it "request success" do
                post user_session_path, params: { user: invalid_user_params }
                expect(response.status).to eq 200
            end
        end

        # ログイン済みユーザー
        context "user is logged in" do
            before do
                sign_in user
            end

            # ログイン済みユーザーはホーム画面にリダイレクトされること
            it "Redirect from login screen to home screen" do
                post user_session_path, params: { user: invalid_user_params }
                expect(response).to redirect_to root_path
            end
        end
    end

    # ユーザーログアウト
    describe "DELETE #destroy" do
        #ログイン済みユーザー
        context "user is logged in" do
            before  do
                sign_in user
            end

            context "Request" do
                # 成功
                it "Success Logout" do
                    delete destroy_user_session_path
                    expect(response.status).to eq 302
                    expect(response).to redirect_to root_path
                end
            end
        end
    end

end