require 'rails_helper'

# コンタクトグループモデル関連テスト
RSpec.describe ContactGroupRelation, type: :model do

    let!(:user){ create(:user) }
    let!(:other_user){ create(:other_user) }
    let!(:contact_group){ user.contact_groups.create(name: "テストグループ") }
    let(:contact_group_relation){ contact_group.contact_group_relations.build(user_id: other_user.id) }

    # 全てのカラムが正の場合
    it "is valid with a user_id and contact_group_id" do
        expect(contact_group_relation).to be_valid
    end

    # ユーザーIDが空の場合
    it "is invalid without a user_id" do
        contact_group_relation.user_id = ""
        expect(contact_group_relation).not_to be_valid
    end

    # コンタクトグループIDが空の場合
    it "is invalid without a contact_group_id" do
        contact_group_relation.contact_group_id = ""
        expect(contact_group_relation).not_to be_valid
    end

end