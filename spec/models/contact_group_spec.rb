require 'rails_helper'

# コンタクトグループモデル関連テスト
RSpec.describe ContactGroup, type: :model do

    let!(:user){ create(:user) }

    # バリデーション関連
    describe "Validation" do

        let(:contact_group){ user.contact_groups.build(name: "テストグループ") }

        # 全てのカラムが正の場合
        it "is valid with a user_id and name" do
            expect(contact_group).to be_valid
        end

        # ユーザーIDが空の場合
        it "is invalid without a user_id" do
            contact_group.user_id = ""
            expect(contact_group).not_to be_valid
        end

        # グループネームが空の場合
        it "is invalid without a name" do
            contact_group.name = ""
            expect(contact_group).not_to be_valid
        end

        # グループネームが11文字以上の場合
        it "is invalid when a name is 11 characters" do
            contact_group.name = "a" * 11
            expect(contact_group).not_to be_valid
        end

    end

    # アソシエーション関連
    describe "Association" do

        let!(:other_user){ create(:other_user) }
        let!(:contact_group){ user.contact_groups.create(name: "テストグループ") }

        # グループ削除時　グループリレーション削除
        it "destroy with destroy contact_group_relation" do
            contact_group_relation = contact_group.contact_group_relations.create(user_id: other_user.id)
            expect { contact_group_relation.destroy }.to change{ ContactGroupRelation.count }.by(-1)
        end

    end

end