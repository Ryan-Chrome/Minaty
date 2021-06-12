require "rails_helper"

RSpec.describe "MeetingRoom", type: :system, js: true do
  let!(:dept) { create(:human_resources_dept) }
  let!(:user) { create(:user, department_id: dept.id) }
  let!(:other_user) { create(:other_user, department_id: dept.id) }
  let(:meeting_room) { create(:meeting_room) }
  let(:entry) { meeting_room.users << user }

  before { login(user) }

  it "ルーム作成動作確認" do
    # ルームエントリーメッセージ確認用
    using_session :userA do
      login(other_user)
    end
    # ルーム一覧でルームがないこと確認
    visit meeting_rooms_path
    expect(find("#rooms-container")).to have_content "該当するルームが存在しません"
    # ルーム新規作成ページへ
    find("#new-room-link").click
    expect(page).to have_css "#meeting-new-form"
    # フォームを空入力で送信
    click_button "ルーム作成"
    # エラー確認
    expect(find("#selected-users")).to have_content "参加するユーザーを\n選択してください"
    expect(all(".field_with_errors").count).to eq 4
    # フォーム入力して送信
    fill_in "ミーティング内容", with: "テスト会議"
    fill_in "meeting_room_meeting_date", with: Date.today
    select "10", from: "meeting_room_start_at_4i"
    select "30", from: "meeting_room_start_at_5i"
    select "23", from: "meeting_room_finish_at_4i"
    select "50", from: "meeting_room_finish_at_5i"
    # エントリーユーザー選択
    find("#entry-select-group-0").click
    find("#entry-select-list-0 li:nth-child(1)").click
    # 選択したユーザーが選択済リストに追加されること
    expect(find("#selected-users")).to have_content "other_user"
    click_button "ルーム作成"
    # ミーティングロビーにリダイレクトされること、作成したルームが表示確認
    expect(find("#rooms-container")).not_to have_content "該当するルームが存在しません"
    expect(page).to have_css "#rooms-container"
    expect(page).to have_css ".room-content"
    # ユーザーAにルーム予約メッセージが送られたか確認
    using_session :userA do
      expect(first(".message-content")).to have_content "ミーティングルームを予約しました。"
    end
  end

  it "ルームページ動作確認" do
    # データ作成
    meeting_room
    entry
    # ルームページへ移動
    visit meeting_room_path(meeting_room.public_uid)
    # マイクボタン確認
    expect(find("#meeting-room-sidebar")).to have_css "#audio-no-mute"
    expect(find("#meeting-room-sidebar")).not_to have_css "#audio-mute"
    find("#audio-no-mute").click
    expect(find("#meeting-room-sidebar")).not_to have_css "#audio-no-mute"
    expect(find("#meeting-room-sidebar")).to have_css "#audio-mute"
    # ビデオボタン確認
    expect(find("#meeting-room-sidebar")).to have_css "#video-no-mute"
    expect(find("#meeting-room-sidebar")).not_to have_css "#video-mute"
    find("#video-no-mute").click
    expect(find("#meeting-room-sidebar")).not_to have_css "#video-no-mute"
    expect(find("#meeting-room-sidebar")).to have_css "#video-mute"
    # エントリーユーザーボタン確認
    expect(find("#meeting-room-sidebar")).to have_css "#room-users"
    expect(page).not_to have_css "#room-users-container"
    find("#room-users").click
    expect(page).to have_css "#room-users-container"
    find("#room-users").click
    expect(page).not_to have_css "#room-users-container"
    # ユーザー招待ボタン確認
    expect(find("#meeting-room-sidebar")).to have_css "#room-invitation"
    expect(page).not_to have_css "#room-invitation-container"
    find("#room-invitation").click
    expect(page).to have_css "#room-invitation-container"
    find("#room-invitation").click
    expect(page).not_to have_css "#room-invitation-container"
    # ルームメッセージボタン確認
    expect(find("#meeting-room-sidebar")).to have_css "#room-message"
    expect(page).not_to have_css "#room-message-container"
    find("#room-message").click
    expect(page).to have_css "#room-message-container"
    find("#room-message").click
    expect(page).not_to have_css "#room-message-container"
    # 外部メッセージボタン確認
    expect(find("#meeting-room-sidebar")).to have_css "#outside-send-message-list"
    expect(page).not_to have_css "#outside-send-message-container"
    find("#outside-send-message-list").click
    expect(page).to have_css "#outside-send-message-container"
    find("#outside-send-message-list").click
    expect(page).not_to have_css "#room-message-container"
    # コンフィグボタン確認
    expect(find("#meeting-room-sidebar")).to have_css "#video-config"
    expect(page).not_to have_css "#video-config-container"
    find("#video-config").click
    expect(page).to have_css "#video-config-container"
    find("#video-config").click
    expect(page).not_to have_css "#video-config-container"
  end

  it "ルーム削除動作確認" do
    meeting_room
    entry
    # ルーム一覧ページ移動
    visit meeting_rooms_path
    expect(page).not_to have_content "該当するルームが存在しません"
    # ルーム削除ボタンクリック
    first(".room-delete-link").click
    expect(page.accept_confirm).to eq "ルーム名: #{meeting_room.name}を削除しますか？"
    # ルーム一覧ページにルームがないこと確認
    expect(page).to have_content "該当するルームが存在しません"
  end
end
