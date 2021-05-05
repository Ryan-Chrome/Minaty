require 'rails_helper'

# ルームメッセージモデル関連テスト
RSpec.describe RoomMessage, type: :model do

    let!(:user){ create(:user) }
    let!(:meeting_room){ create(:meeting_room) }
    let(:room_message){ meeting_room.room_messages.build(user_id: user.id, content: "テスト") }

    # 全てのカラムが正の場合
    it "is valid with a user_id and meeting_room_id and content" do
        expect(room_message).to be_valid
    end

    # ユーザーIDが空の場合
    it "is invalid without a user_id" do
        room_message.user_id = ""
        expect(room_message).not_to be_valid
    end

    # ミーティングルームIDが空の場合
    it "is invalid without a meeting_room_id" do
        room_message.meeting_room_id = ""
        expect(room_message).not_to be_valid
    end

    # コンテンツが空の場合
    it "is invalid without a content" do
        room_message.content = ""
        expect(room_message).not_to be_valid
    end

    # コンテンツが401文字以上の場合
    it "is invalid when a content is 401 character" do
        room_message.content = "a" * 401
        expect(room_message).not_to be_valid
    end

end