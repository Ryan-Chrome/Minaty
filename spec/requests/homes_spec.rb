require "rails_helper"

RSpec.describe "Home", type: :request do
  let!(:dept) { create(:human_resources_dept) }
  let!(:user) { create(:user, department_id: dept.id) }

  context "ログイン済" do
    before { sign_in user }
    
    it "リクエスト成功" do
      get root_path
      expect(response.status).to eq 200
    end

    it "ログイン済ホーム画面表示" do
      get root_path
      expect(response.body).to include "チャットフォーム"
    end
  end

  context "未ログイン" do
    it "リクエスト成功" do
      get root_path
      expect(response.status).to eq 200
    end

    it "未ログインホーム画面表示" do
      get root_path
      expect(response.body).to include "Login"
    end
  end
end
