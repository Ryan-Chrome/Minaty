require "rails_helper"

RSpec.describe MeetingRoom, type: :model do
  # バリデーション関連
  describe "Validation" do
    let(:meeting_room) { build(:meeting_room) }

    it "全てのカラムが正常" do
      expect(meeting_room).to be_valid
    end

    it "ルーム名が空の場合" do
      meeting_room.name = ""
      expect(meeting_room).not_to be_valid
    end

    it "ルーム名が15文字より長い場合" do
      meeting_room.name = "#{"a" * 16}"
      expect(meeting_room).not_to be_valid
    end

    it "コメントが400文字より長い場合" do
      meeting_room.comment = "#{"a" * 401}"
      expect(meeting_room).not_to be_valid
    end

    it "開始時刻が空の場合" do
      meeting_room.start_at = ""
      expect(meeting_room).not_to be_valid
    end

    it "終了時刻が空の場合" do
      meeting_room.finish_at = ""
      expect(meeting_room).not_to be_valid
    end

    it "開始時刻が終了時刻より遅い場合" do
      meeting_room.start_at = "#{Date.today} 19:00:00"
      meeting_room.finish_at = "#{Date.today} 15:00:00"
      expect(meeting_room).not_to be_valid
    end

    it "開始時刻と終了時刻の日付が違う場合" do
      meeting_room.start_at = "#{Date.today} 12:00:00"
      meeting_room.finish_at = "#{Date.today + 5.day} 19:00:00"
      expect(meeting_room).not_to be_valid
    end

    it "日付が空の場合" do
      meeting_room.meeting_date = ""
      expect(meeting_room).not_to be_valid
    end

    it "日付が今日より前の場合" do
      meeting_room.meeting_date = Date.parse("#{Date.today - 1.day}")
      expect(meeting_room).not_to be_valid
    end

    it "エントリーするユーザーがない場合" do
      meeting_room.room_entry_users = ""
      expect(meeting_room).not_to be_valid
    end
  end

  # アソシエーション関連
  describe "Association" do
    let!(:human_resources_dept) { create(:human_resources_dept) }
    let!(:user) { create(:user, department_id: human_resources_dept.id) }
    let!(:meeting_room) { create(:meeting_room) }
    let!(:entry) { meeting_room.users << user }
    let!(:room_message) { meeting_room.room_messages.create(user_id: user.id, content: "テスト") }

    it "ルーム削除時、エントリー削除とルームメッセージ削除" do
      expect { 
        meeting_room.destroy 
      }.to change {
        Entry.count
      }.by(-1).and change {
        RoomMessage.count
      }.by(-1)
      sleep 0.5 #スリープないと次のテスト失敗する
    end
  end
end
