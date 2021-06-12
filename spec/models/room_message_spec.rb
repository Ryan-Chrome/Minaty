require "rails_helper"

RSpec.describe RoomMessage, type: :model do
  let!(:dept) { create(:human_resources_dept) }
  let!(:user) { create(:user, department_id: dept.id) }
  let!(:meeting_room) { create(:meeting_room) }
  let(:room_message) { meeting_room.room_messages.build(user_id: user.id, content: "テスト") }

  it "全てのカラムが正常" do
    expect(room_message).to be_valid
  end

  it "ユーザーIDが空の場合" do
    room_message.user_id = ""
    expect(room_message).not_to be_valid
  end

  it "ルームIDが空の場合" do
    room_message.meeting_room_id = ""
    expect(room_message).not_to be_valid
  end

  it "コンテンツが空の場合" do
    room_message.content = ""
    expect(room_message).not_to be_valid
  end

  it "コンテンツが400文字より長い場合" do
    room_message.content = "a" * 401
    expect(room_message).not_to be_valid
  end
end
