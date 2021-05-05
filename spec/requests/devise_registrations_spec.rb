require 'rails_helper'

RSpec.describe "UserAuthentications", type: :request do
    
    let!(:admin_user){ create(:admin_user) }
    let(:user_params){ attributes_for(:user) }
    let(:invalid_user_params){ attributes_for(:user, name: "") }

    # ユーザー新規作成
    describe "POST #create" do
        # ログイン
        before do
            sign_in admin_user
        end

        # 有効なパラメータを渡された場合
        context "If the parameters are valid" do
            it "request success" do
                post user_registration_path, params: { user: user_params }
                expect(response.status).to eq 302
            end

            it "create success" do
                expect do
                    post user_registration_path, params: { user: user_params }
                end.to change{ User.count }.by(1)
            end

            it "redirect" do
                post user_registration_path, params: { user: user_params }
                expect(response).to redirect_to managements_path
            end
        end

        # 無効なパラメーターを渡された場合
        context "If the parameters are invalid" do
            it "request success" do
                post user_registration_path, params: { user: invalid_user_params }
                expect(response.status).to eq 200
            end

            it "create error" do
                expect do
                    post user_registration_path, params: { user: invalid_user_params }
                end.to change{ User.count }.by(0)
            end
        end
    end

end