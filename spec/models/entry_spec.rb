require 'rails_helper'

# ルームエントリーモデル関連テスト
RSpec.describe Entry, type: :model do

    let!(:user){ create(:user) }
    let!(:meeting_room){ create(:meeting_room) }
    let(:entry){ meeting_room.entries.build(user_id: user.id) }

    # 全てのカラムが正の場合
    it "is valid with a user_id and meeting_room_id" do
        expect(entry).to be_valid
    end

    # ユーザーIDが空の場合
    it "is invalid without a user_id" do
        entry.user_id = ""
        expect(entry).not_to be_valid
    end

    # ミーティングルームIDが空の場合
    it "is invalid without a meeting_room_id" do
        entry.meeting_room_id = ""
        expect(entry).not_to be_valid
    end

end