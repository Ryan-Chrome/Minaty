require 'rails_helper'

RSpec.describe "Home", type: :request do
    let!(:user){ create(:user) }

    # ログイン済みユーザー
    context "user is logged in" do
        before do
            sign_in user
        end

        it "request success" do
            get root_path
            expect(response.status).to eq 200
            expect(response.body).to match(/<h6><i class="fas fa-comment"><\/i> チャットフォーム<\/h6>/i)
        end
    end

    # 未ログインユーザー
    context "user is not logged in" do
        it "request success" do
            get root_path
            expect(response.status).to eq 200
        end
    end

end