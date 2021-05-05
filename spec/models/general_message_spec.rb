require 'rails_helper'

# ジェネラルメッセージモデル関連テスト
RSpec.describe GeneralMessage, type: :model do

    let!(:user){ create(:user) }

    # バリデーション関連
    describe "Validation" do
        
        let(:general_message){ user.general_messages.build(content: "テストテキスト") }
    
        # 全てのカラムが正の場合
        it "is valid with a content and user_id" do
            expect(general_message).to be_valid
        end

        # ユーザーIDが空の場合
        it "is invalid without a user_id" do
            general_message.user_id = ""
            expect(general_message).not_to be_valid
        end

        # コンテンツが空の場合
        it "is invaild without a content" do
            general_message.content = ""
            expect(general_message).not_to be_valid
        end

        # コンテンツが401文字以上の場合
        it "is invalid when a content is 401 character" do
            general_message.content = "a" * 401
            expect(general_message).not_to be_valid
        end

    end

    # アソシエーション関連
    describe "Association" do

        let(:other_user){ FactoryBot.create(:other_user) }
        let(:general_message){ user.general_messages.create(content: "テストテキスト") }

        # メッセージ削除時　メッセージリレーション削除
        it "destroy with destroy general_message_relation" do
            general_message.general_message_relations.create(user_id: user.id, receive_user_id: other_user.id)
            expect { general_message.destroy }.to change{ GeneralMessageRelation.count }.by(-1)
        end

    end

end