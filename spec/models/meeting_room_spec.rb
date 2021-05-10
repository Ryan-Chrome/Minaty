require 'rails_helper'

# ミーティングルームモデル関連テスト
RSpec.describe MeetingRoom, type: :model do

    # バリデーション関連
    describe "Validation" do

        # 全てのカラムが正の場合
        it "is valid with a user_id and name and start_time and end_time" do
            expect(FactoryBot.build(:meeting_room)).to be_valid
        end

        # 名前が空の場合
        it "is invalid without a name" do
            expect(FactoryBot.build(:meeting_room, name: "")).not_to be_valid
        end

        # 名前が16文字以上の場合
        it "is invalid when a name is 16 characters" do
            expect(FactoryBot.build(:meeting_room, name: "#{"a" * 16}")).not_to be_valid
        end

        # 開始時刻が空の場合
        it "is invalid without a start_time" do
            expect(FactoryBot.build(:meeting_room, start_at: "")).not_to be_valid
        end

        # 終了時刻が空の場合
        it "is invalid without a end_time" do
            expect(FactoryBot.build(:meeting_room, finish_at: "")).not_to be_valid
        end

        # 開始時刻が終了時刻より遅い場合
        it "is invalid meeting_start_end_check" do
            expect(MeetingRoom.new(name: "会議", start_at: "2021-02-10 19:00:00", finish_at: "2021-02-10 15:00:00")).not_to be_valid
        end

        # 開始時刻と終了時刻の日付が違う場合
        it "is invalid meeting_date_check" do
            expect(MeetingRoom.new(name: "会議", start_at: "2021-02-10 12:00:00", finish_at: "2021-02-11 19:00:00")).not_to be_valid
        end

        # エントリーするユーザーが送られなかった場合
        it "is invalid room_entry_users" do
            expect(FactoryBot.build(:meeting_room, room_entry_users: "")).not_to be_valid
        end

        # コメントが400字以上の場合
        it "is invalid comment" do
            expect(FactoryBot.build(:meeting_room, comment: "#{"a" * 401}")).not_to be_valid
        end

    end

    # アソシエーション関連
    describe "Association" do

        let!(:user){ create(:user) }
        let!(:meeting_room){ create(:meeting_room) }

        # ミーティングルーム削除時　エントリー削除
        it "destroy with destroy entry" do
            meeting_room.entries.create(user_id: user.id)
            expect { meeting_room.destroy }.to change{ Entry.count }.by(-1)
            sleep 0.5 #スリープないと次のテスト失敗する
        end

        # ミーティングルーム削除時　ルームメッセージ削除
        it "destroy with destroy room_message" do
            meeting_room.room_messages.create(user_id: user.id, content: "テスト")
            expect { meeting_room.destroy }.to change{ RoomMessage.count }.by(-1)
            sleep 0.5 #スリープないと次のテスト失敗する
        end

    end

end