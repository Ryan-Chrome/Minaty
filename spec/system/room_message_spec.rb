require "rails_helper"

RSpec.describe "RoomMessage", type: :system, js: true do
  let!(:dept) { create(:human_resources_dept) }
  let!(:user) { create(:user, department_id: dept.id) }
  let!(:other_user) { create(:other_user, department_id: dept.id) }
  let!(:therd_user) { create(:therd_user, department_id: dept.id) }
  let!(:meeting_room) { create(:meeting_room) }
  let!(:entry) { meeting_room.users << [user, other_user, therd_user] }

  before { login(user) }

  it "ルームメッセージ作成動作確認" do
    # ルームメッセージ受信確認用
    using_session :userA do
      login(other_user)
      # ミーティングルームへ
      visit meeting_room_path(meeting_room.public_uid)
      # ルームチャットコンテナ表示
      find("#room-message").click
      # メッセージがないこと確認
      expect(find("#room-message-container")).not_to have_content "テキスト"
    end
    # ルームメッセージ受信アイコン確認用
    using_session :userB do
      login(therd_user)
      # ミーティングルームへ
      visit meeting_room_path(meeting_room.public_uid)
      # アイコンないこと確認
      expect(find("#meeting-room-sidebar")).not_to have_css "#room-chat-notice"
    end
    # ミーティングルームへ
    visit meeting_room_path(meeting_room.public_uid)
    # ルームチャットコンテナ表示
    find("#room-message").click
    expect(page).to have_css "#room-message-container"
    # メッセージがないこと確認
    expect(find("#room-message-container")).not_to have_content "テキスト"
    # フォーム空入力、送信
    click_on "送信"
    # エラーメッセージ確認
    expect(page.accept_confirm).to eq "メッセージを入力してください"
    # フォーム入力、送信
    fill_in "room-message-textarea", with: "テキスト"
    click_on "送信"
    # メッセージ追加されていること確認
    expect(find("#room-message-container")).to have_content "テキスト"
    # メッセージ受信確認
    using_session :userA do
      # メッセージ追加されていること確認
      expect(find("#room-message-container")).to have_content "テキスト"
    end
    # メッセージアイコン受信確認
    using_session :userB do
      # アイコンあること確認
      expect(find("#meeting-room-sidebar")).to have_css "#room-chat-notice"
    end
  end
end