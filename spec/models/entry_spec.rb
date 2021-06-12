require "rails_helper"

RSpec.describe Entry, type: :model do
  let!(:dept) { create(:human_resources_dept) }
  let!(:user) { create(:user, department_id: dept.id) }
  let!(:meeting_room) { create(:meeting_room) }
  let(:entry) { meeting_room.entries.build(user_id: user.id) }

  it "全てのカラムが正常" do
    expect(entry).to be_valid
  end

  it "ユーザーIDが空の場合" do
    entry.user_id = ""
    expect(entry).not_to be_valid
  end

  it "ミーティングルームIDが空の場合" do
    entry.meeting_room_id = ""
    expect(entry).not_to be_valid
  end

  it "ユーザーIDとミーティングルームIDの組み合わせが既に存在する場合" do
    meeting_room.users << user
    expect(entry).not_to be_valid
  end
end
