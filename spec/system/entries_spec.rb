require "rails_helper"

RSpec.describe "Entry", type: :system, js: true do
  let!(:dept) { create(:human_resources_dept) }
  let!(:user) { create(:user, department_id: dept.id) }
  let!(:other_user) { create(:other_user, department_id: dept.id) }
  let!(:therd_user) { create(:therd_user, department_id: dept.id) }
  let!(:meeting_room) { create(:meeting_room) }
  let!(:entry) { meeting_room.users << user }
  let!(:other_user_entry) { meeting_room.users << other_user }

  before { login(user) }

  it "ルーム招待動作確認" do
    # ルーム内でのエントリーユーザーリスト変化確認用
    using_session :userA do
      login(other_user)
      # ルームへ移動
      visit meeting_room_path(meeting_room.public_uid)
      # ルームのエントリーリストを開いてtherd_userがいないことを確認
      find("#room-users").click
      expect(find("#room-users-container")).not_to have_content "therd_user"
    end
    # 招待メッセージ確認用
    using_session :userB do
      login(therd_user)
    end
    # ルームへ移動
    visit meeting_room_path(meeting_room.public_uid)
    # ルームのエントリーリストを開いてtherd_userがいないことを確認
    find("#room-users").click
    expect(find("#room-users-container")).not_to have_content "therd_user"
    # 招待リストを開いてtherd_userを招待
    find("#room-invitation").click
    find("#invitation-user-#{therd_user.public_uid} input").click
    # 招待リストからtherd_userが消えていることを確認
    expect(find("#room-invitation-container")).not_to have_css "#invitation-user-#{therd_user.public_uid}"
    # ルームのエントリーリストを開いてtherd_userが追加されていことを確認
    find("#room-users").click
    expect(find("#room-users-container")).to have_content "therd_user"
    # 招待メッセージを送信したことを確認
    visit root_path
    expect(first(".message-content")).to have_content "ルームに招待しました。"
    # ユーザーAでエントリーリストにtherd_userがあることを確認
    using_session :userA do
      expect(find("#room-users-container")).to have_content "therd_user"
      # 招待リストを開いてtherd_userがないことを確認
      find("#room-invitation").click
      expect(find("#room-invitation-container")).not_to have_css "#invitation-user-#{therd_user.public_uid}"
    end
    # ユーザーBで招待メッセージが送られたことを確認
    using_session :userB do
      expect(first(".message-content")).to have_content "ルームに招待しました。"
    end
  end
end