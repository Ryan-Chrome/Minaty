require "rails_helper"

RSpec.describe "GeneralMessage", type: :system, js: true do
  let!(:dept) { create(:human_resources_dept) }
  let!(:user) { create(:user, department_id: dept.id) }
  let!(:other_user) { create(:other_user, department_id: dept.id) }
  let!(:therd_user) { create(:therd_user, department_id: dept.id) }
  let(:create_message) { user.general_messages.create(content: "テスト") }
  let(:create_room) { create(:meeting_room) }

  before { login(user) }

  it "送信先一覧表示動作確認" do
    # メッセージ作成、送信先追加
    create_message
    create_message.receive_users << other_user
    # ページリロード
    visit current_path
    # 送信先一覧がないこと確認
    expect(page).not_to have_css "#message-receivers-container"
    # 送信先一覧ボタンクリック
    first(".send-users-display-btn").click
    # 送信先一覧があること確認
    expect(page).to have_css "#message-receivers-container"
    # 送信先一覧閉じる
    find("#message-receivers-close").click
    # 送信先一覧がないこと確認
    expect(page).not_to have_css "#message-receivers-container"
  end

  it "ユーザー詳細からのメッセージ作成動作確認" do
    # メッセージ受信確認ユーザーセッション
    using_session :userA do
      login(other_user)
      # ホームチャットコンテンツにメッセージがないこと確認
      expect(find("#chat-content")).not_to have_content "テキスト"
      # ユーザー詳細モーダル表示
      click_on "#{dept.name}"
      click_on "#{user.name}"
      # ユーザー詳細モーダル表示、メッセージがないこと確認
      expect(page).to have_css "#user-content"
      expect(find("#chat-log")).not_to have_content "テキスト"
    end
    # ホームチャットコンテンツにメッセージがないこと確認
    expect(find("#chat-content")).not_to have_content "テキスト"
    # サイドユーザーリストの部署グループクリック
    click_on "#{dept.name}"
    # ユーザー詳細モーダル表示
    click_on "#{other_user.name}"
    # ユーザー詳細モーダル表示、メッセージがないこと確認
    expect(page).to have_css "#user-content"
    expect(find("#chat-log")).not_to have_content "テキスト"
    # フォーム空入力、送信
    click_on "chat-send-btn"
    expect(page.accept_confirm).to eq "送信内容に不備があります。"
    # フォーム入力、送信
    fill_in "user-content-chat-text-area", with: "テキスト"
    click_on "chat-send-btn"
    # メッセージ表示確認
    expect(find("#chat-log")).to have_content "テキスト"
    # ユーザー詳細モーダル閉じる
    find("#user-content-close").click
    # ユーザー詳細モーダル閉じていること確認
    expect(page).not_to have_css "#user-content"
    # ホームチャットコンテンツにメッセージ追加されていること確認
    expect(find("#chat-content")).to have_content "テキスト"
    # 送信先ユーザーでメッセージ受信確認
    using_session :userA do
      # メッセージ受信確認
      expect(find("#chat-log")).to have_content "テキスト"
      # ユーザー詳細モーダル閉じる
      find("#user-content-close").click
      expect(page).not_to have_css "#user-content"
      # ホームチャットコンテンツにメッセージが追加されていること確認
      expect(find("#chat-content")).to have_content "テキスト"
    end
  end

  it "ホームからのメッセージ作成動作確認" do
    # ホームチャットコンテンツでのメッセージ受信確認ユーザーセッション
    using_session :userA do
      login(other_user)
      # ホームチャットコンテンツにメッセージがないこと確認
      expect(find("#chat-content")).not_to have_content "テキスト"
    end
    # ユーザー詳細モーダルチャットでのメッセージ受信確認ユーザーセッション
    using_session :userB do
      login(therd_user)
      # ユーザー詳細モーダル表示
      click_on "#{dept.name}"
      click_on "#{user.name}"
      # ユーザー詳細モーダル表示、メッセージがないこと確認
      expect(page).to have_css "#user-content"
      expect(find("#chat-log")).not_to have_content "テキスト"
    end
    # 宛先空入力、送信
    fill_in "chat-text-area", with: "テキスト"
    click_on "home-chat-send-btn"
    # エラーメッセージ確認
    expect(page.accept_confirm).to eq "送信先もしくは内容に不備があります。"
    # テキストエリア空入力、送信
    fill_in "chat-text-area", with: ""
    # 送信先ユーザー選択フォーム
    find("#add-send-user").click
    first("#send-list .group-container").click
    first("#send-list .user-selector-#{other_user.public_uid}").click
    first("#send-list .user-selector-#{therd_user.public_uid}").click
    click_on "完了"
    # 宛先リストにユーザーが追加されているか確認
    expect(find("#chat-send-user-list")).to have_selector "#send-selected-user-#{other_user.public_uid}"
    expect(find("#chat-send-user-list")).to have_selector "#send-selected-user-#{therd_user.public_uid}"
    click_on "home-chat-send-btn"
    # エラーメッセージ確認
    expect(page.accept_confirm).to eq "送信先もしくは内容に不備があります。"
    # テキストエリア入力、送信
    fill_in "chat-text-area", with: "テキスト"
    click_on "home-chat-send-btn"
    # 自分のチャットフォームにメッセージが追加されたか確認
    expect(find("#chat-content")).to have_content "テキスト"
    # userAでホームチャットコンテンツにメッセージ追加されているか確認
    using_session :userA do
      expect(find("#chat-content")).to have_content "テキスト"
    end
    # userBでユーザー詳細モーダルチャットにメッセージが追加されているか確認
    using_session :userB do
      expect(find("#chat-log")).to have_content "テキスト"
    end
  end

  it "メッセージ送信時お知らせ動作確認" do
    # ルームデータ作成
    create_room
    create_room.users << therd_user
    # お知らせ確認用ユーザーセッション
    using_session :userA do
      login(other_user)
      # ダッシュボードへ
      visit user_path(other_user.public_uid)
      # お知らせがないこと確認
      expect(page).not_to have_css "#notice-message-container"
    end
    # ルーム内でのサイドチャットボタンお知らせ確認用ユーザーセッション
    using_session :userB do
      login(therd_user)
      # ルームページへ
      visit meeting_room_path(create_room.public_uid)
      # 受信アイコンないこと確認
      expect(find("#meeting-room-sidebar")).not_to have_css "#room-chat-notice"
    end
    # メッセージ送信
    find("#add-send-user").click
    first("#send-list .group-container").click
    first("#send-list .user-selector-#{other_user.public_uid}").click
    first("#send-list .user-selector-#{therd_user.public_uid}").click
    click_on "完了"
    fill_in "chat-text-area", with: "テキスト"
    click_on "home-chat-send-btn"
    # お知らせ表示されていること確認
    using_session :userA do
      # お知らせが追加されてること確認
      expect(page).to have_css "#notice-message-container"
      expect(find("#notice-message-container")).to have_content "#{user.name}から、メッセージを受信しました。"
    end
    # ルーム内でのサイドチャットボタンにマークが表示されること確認
    using_session :userB do
      # 受信アイコンあること確認
      expect(find("#meeting-room-sidebar")).to have_css "#room-chat-notice"
    end
  end
end
