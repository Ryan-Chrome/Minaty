require 'rails_helper'

# ジェネラルメッセージリレーションモデル関連テスト
RSpec.describe GeneralMessageRelation, type: :model do

    let!(:user){ create(:user) }
    let!(:other_user){ create(:other_user) }
    let!(:general_message){ user.general_messages.create(content: "テストテキスト") }
    let(:general_message_relation){ general_message.general_message_relations.build(user_id: user.id, receive_user_id: other_user.id) }

    # 全てのカラムが正の場合
    it "is valid with a user_id and receive_user_id and general_message_id" do
        expect(general_message_relation).to be_valid
    end

    # 送信ユーザーIDが空の場合
    it "is invalid without a user_id" do
        general_message_relation.user_id = ""
        expect(general_message_relation).not_to be_valid
    end

    # 受信ユーザーIDが空の場合
    it "is invalid without a receive_user_id" do
        general_message_relation.receive_user_id = ""
        expect(general_message_relation).not_to be_valid
    end

    # ジェネラルメッセージIDが空の場合
    it "is invalid without a general_message_id" do
        general_message_relation.general_message_id = ""
        expect(general_message_relation).not_to be_valid
    end

end