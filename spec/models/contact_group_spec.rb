require "rails_helper"

RSpec.describe ContactGroup, type: :model do
  let!(:dept) { create(:human_resources_dept) }
  let!(:user) { create(:user, department_id: dept.id) }

  # バリデーション関連
  describe "Validation" do
    let(:contact_group) { build(:contact_group, user_id: user.id) }

    it "全てのカラムが正常" do
      expect(contact_group).to be_valid
    end

    it "ユーザーIDが空の場合" do
      contact_group.user_id = ""
      expect(contact_group).not_to be_valid
    end

    it "グループネームが空の場合" do
      contact_group.name = ""
      expect(contact_group).not_to be_valid
    end

    it "グループネームの文字数が10文字より長い場合" do
      contact_group.name = "a" * 11
      expect(contact_group).not_to be_valid
    end
  end

  # アソシエーション関連
  describe "Association" do
    let!(:other_user) { create(:other_user, department_id: dept.id) }
    let!(:contact_group) { create(:contact_group, user_id: user.id) }
    let!(:relation) { contact_group.users << other_user }

    it "グループ削除時、グループリレーション削除" do
      expect { contact_group.destroy }.to change { ContactGroupRelation.count }.by(-1)
    end
  end
end
