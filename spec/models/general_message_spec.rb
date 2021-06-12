require "rails_helper"

RSpec.describe GeneralMessage, type: :model do
  let!(:dept) { create(:human_resources_dept) }
  let!(:user) { create(:user, department_id: dept.id) }

  # バリデーション関連
  describe "Validation" do
    let(:general_message) { user.general_messages.build(content: "テストテキスト") }

    it "全てのカラムが正常" do
      expect(general_message).to be_valid
    end

    it "ユーザーIDが空の場合" do
      general_message.user_id = ""
      expect(general_message).not_to be_valid
    end

    it "メッセージ内容が空の場合" do
      general_message.content = ""
      expect(general_message).not_to be_valid
    end

    it "メッセージ内容が400文字より長い場合" do
      general_message.content = "a" * 401
      expect(general_message).not_to be_valid
      sleep 0.2
    end
  end

  # アソシエーション関連
  describe "Association" do
    let!(:other_user) { create(:other_user, department_id: dept.id) }
    let!(:general_message) { user.general_messages.create(content: "テストテキスト") }

    it "メッセージ削除時リレーション削除" do
      general_message.receive_users << other_user
      expect { general_message.destroy }.to change { GeneralMessageRelation.count }.by(-1)
    end
  end
end
