require "rails_helper"

RSpec.describe "Schedule", type: :system, js: true do
  let!(:dept) { create(:human_resources_dept) }
  let!(:user) { create(:user, department_id: dept.id) }
  
  let(:other_user) { create(:other_user, department_id: dept.id) }

  let(:meeting_room) { create(:meeting_room) }
  let(:entry) { meeting_room.users << user }

  let(:schedule) { create(:schedule, user_id: user.id) }

  before { login(user) }

  it "ホーム画面からのスケジュール作成動作確認" do
    # スケジュール新規作成日付選択フォーム表示
    expect(page).not_to have_css "#add-schedule-data"
    click_on "add-schedule-btn"
    expect(page).to have_css "#add-schedule-data"
    # スケジュール新規作成フォーム表示
    expect(page).not_to have_css "#add-schedule-next"
    click_on "次へ"
    expect(page).to have_css "#add-schedule-next"
    # フォーム空入力、送信
    click_button "登録"
    # エラーメッセージが表示されていること確認
    expect(page).to have_content "処理に失敗しました。"
    # スケジュールがないこと確認
    expect(page).not_to have_css "#add-schedule-name-0", text: "テスト"
    expect(page).not_to have_css "#add-schedule-time-0", text: "10:00~15:30"
    # フォーム入力、送信
    fill_in "内容", with: "テスト"
    select "10", from: "schedule_start_at_4i"
    select "00", from: "schedule_start_at_5i"
    select "15", from: "schedule_finish_at_4i"
    select "30", from: "schedule_finish_at_5i"
    click_button "登録"
    # 追加完了メッセージ表示されていること確認
    expect(page).to have_content "スケジュールを追加しました。"
    # スケジュールが追加されていること確認
    expect(page).to have_css "#add-schedule-name-0", text: "テスト"
    expect(page).to have_css "#add-schedule-time-0", text: "10:00~15:30"
    # モーダル戻るボタンでスケジュール新規作成日付選択フォーム表示
    expect(page).not_to have_css "#add-schedule-data"
    find("#add-schedule-next-back").click
    expect(page).not_to have_css "#add-schedule-next"
    expect(page).to have_css "#add-schedule-data"
    # モーダル閉じるボタンでスケジュール新規作成日付選択フォーム閉じる
    find("#add-schedule-data-close").click
    expect(page).not_to have_css "#add-schedule-data"
    # スケジュール新規作成日付選択フォーム表示
    click_on "add-schedule-btn"
    expect(page).to have_css "#add-schedule-data"
    # スケジュール新規作成フォーム表示
    click_on "次へ"
    # モーダル閉じるボタンでスケジュール新規作成フォーム閉じる
    expect(page).to have_css "#add-schedule-next"
    find("#add-schedule-next-close").click
    expect(page).not_to have_css "#add-schedule-next"
  end

  it "ルームエントリー通知からのスケジュール作成動作確認" do
    # データ作成
    other_user
    # ミーティングルーム新規作成画面表示
    visit new_meeting_room_path
    # ルーム作成
    fill_in "ミーティング内容", with: "テスト会議"
    fill_in "meeting_room_meeting_date", with: Date.today
    fill_in "meeting_room_comment", with: "テストコメント"
    select "10", from: "meeting_room_start_at_4i"
    select "30", from: "meeting_room_start_at_5i"
    select "20", from: "meeting_room_finish_at_4i"
    select "00", from: "meeting_room_finish_at_5i"
    find("#entry-select-group-0").click
    find("#entry-select-list-0 li:nth-child(1)").click
    click_button "ルーム作成"
    # ホーム画面表示
    visit root_path
    # ルームエントリー通知メッセージからスケジュール新規作成フォーム表示
    expect(page).not_to have_css "#add-schedule-next"
    first(".schedule-add-meeting").click
    expect(page).to have_css "#add-schedule-next"
    # フォームにルームの情報が既に入力されているか確認
    expect(find("#add-schedule-next")).to have_field "内容", with: "テスト会議"
    expect(find("#add-schedule-next")).to have_select("schedule_start_at_4i", selected: "10")
    expect(find("#add-schedule-next")).to have_select("schedule_start_at_5i", selected: "30")
    expect(find("#add-schedule-next")).to have_select("schedule_finish_at_4i", selected: "20")
    expect(find("#add-schedule-next")).to have_select("schedule_finish_at_5i", selected: "00")
    # 登録ボタンクリック
    click_button "登録"
    # 追加完了メッセージ表示されていること確認
    expect(page).to have_content "スケジュールを追加しました。"
    # スケジュールが追加されていること確認
    expect(page).to have_css "#add-schedule-name-0", text: "テスト会議"
    expect(page).to have_css "#add-schedule-time-0", text: "10:30~20:00"
  end

  it "ホーム画面タイマーからのスケジュール作成動作確認" do
    # タイマーボタンクリック
    find("#header-time-btn").click
    # タイマースタート
    find("#timer-start").click
    sleep 1
    # タイマーストップ
    find("#timer-stop").click
    # タイマーのスケジュール追加ボタンクリック、スケジュール新規作成フォーム表示
    expect(page).not_to have_css "#add-schedule-next"
    find("#timer-add-schedule").click
    expect(page).to have_css "#add-schedule-next"
    # フォーム入力、送信
    fill_in "内容", with: "テスト"
    select "10", from: "schedule_start_at_4i"
    select "00", from: "schedule_start_at_5i"
    select "15", from: "schedule_finish_at_4i"
    select "30", from: "schedule_finish_at_5i"
    click_button "登録"
    # 追加完了メッセージ表示されていること確認
    expect(page).to have_content "スケジュールを追加しました。"
    # スケジュールが追加されていること確認
    expect(page).to have_css "#add-schedule-name-0", text: "テスト"
    expect(page).to have_css "#add-schedule-time-0", text: "10:00~15:30"
  end

  it "ミーティングルーム画面タイマーからのスケジュール作成動作確認" do
    # データ作成
    meeting_room
    entry
    # ミーティングルーム表示
    visit meeting_room_path(meeting_room.public_uid)
    # タイマーボタンクリック
    find("#header-time-btn").click
    # タイマースタート
    find("#timer-start").click
    sleep 1
    # タイマーストップ
    find("#timer-stop").click
    # タイマーのスケジュール追加ボタンクリック、スケジュール新規作成フォーム表示
    expect(page).not_to have_css "#add-schedule-next"
    find("#timer-add-schedule").click
    expect(page).to have_css "#add-schedule-next"
    # フォーム入力、送信
    fill_in "内容", with: "テスト"
    select "10", from: "schedule_start_at_4i"
    select "00", from: "schedule_start_at_5i"
    select "15", from: "schedule_finish_at_4i"
    select "30", from: "schedule_finish_at_5i"
    click_button "登録"
    # 追加完了メッセージ表示されていること確認
    expect(page).to have_content "スケジュールを追加しました。"
    # スケジュールが追加されていること確認
    expect(page).to have_css "#add-schedule-name-0", text: "テスト"
    expect(page).to have_css "#add-schedule-time-0", text: "10:00~15:30"
  end

  it "スケジュール編集動作確認" do
    # 編集用データ作成
    schedule
    # ページリロード
    visit current_path
    # 編集スケジュール選択モーダル表示
    expect(page).not_to have_css "#edit-schedule"
    click_on "edit-schedule-btn"
    expect(page).to have_css "#edit-schedule"
    # 編集スケジュール選択
    expect(page).not_to have_css "#edit-schedule-next"
    first(".edit-schedule-0").click
    expect(page).to have_css "#edit-schedule-next"
    # 編集フォームに入力されていること確認
    expect(find("#edit-schedule-next")).to have_field "内容", with: "#{schedule.name}"
    expect(find("#edit-schedule-next")).to have_select(
      "schedule_edit_start_at_4i", selected: "#{schedule.start_at[0..1]}"
    )
    expect(find("#edit-schedule-next")).to have_select(
      "schedule_edit_start_at_5i", selected: "#{schedule.start_at[3..4]}"
    )
    expect(find("#edit-schedule-next")).to have_select(
      "schedule_edit_finish_at_4i", selected: "#{schedule.finish_at[0..1]}"
    )
    expect(find("#edit-schedule-next")).to have_select(
      "schedule_edit_finish_at_5i", selected: "#{schedule.finish_at[3..4]}"
    )
    # フォーム空入力、送信
    fill_in "内容", with: ""
    click_on "変更"
    # 編集失敗メッセージ表示されること確認
    expect(page).to have_content "編集に失敗しました。"
    # フォーム入力、送信
    fill_in "内容", with: "編集スケジュール"
    select "10", from: "schedule_edit_start_at_4i"
    select "00", from: "schedule_edit_start_at_5i"
    select "15", from: "schedule_edit_finish_at_4i"
    select "30", from: "schedule_edit_finish_at_5i"
    click_on "変更"
    # 編集成功メッセージが表示されること確認
    expect(page).to have_content "スケジュールを編集しました。"
    # 編集スケジュール選択画面のスケジュールが変更されていること
    expect(page).to have_css "#edit-schedule-name-0", text: "編集スケジュール"
    expect(page).to have_css "#edit-time-0", text: "10:00~15:30"
    # 編集スケジュール選択モーダルが表示されること確認
    expect(page).not_to have_css "#edit-schedule-next"
    expect(page).to have_css "#edit-schedule"
    # 編集スケジュール選択モーダル閉じるボタンクリック
    find("#edit-schedule-close").click
    expect(page).not_to have_css "#edit-schedule"
  end

  it "スケジュール削除動作確認" do
    # 削除用データ作成
    schedule
    # ページリロード
    visit current_path
    # 編集スケジュール選択モーダル表示
    expect(page).not_to have_css "#edit-schedule"
    click_on "edit-schedule-btn"
    expect(page).to have_css "#edit-schedule"
    # 編集スケジュール選択画面のスケジュールの存在確認
    expect(page).to have_css "#edit-schedule-name-0", text: "#{schedule.name}"
    expect(page).to have_css "#edit-time-0", text: "#{schedule.start_at}~#{schedule.finish_at}"
    # 編集スケジュール選択
    expect(page).not_to have_css "#edit-schedule-next"
    first(".edit-schedule-0").click
    expect(page).to have_css "#edit-schedule-next"
    # 削除ボタンクリック
    click_on "削除"
    # 削除成功メッセージが表示されること確認
    expect(page).to have_content "スケジュールを削除しました"
    # 編集スケジュール選択画面にスケジュールが存在しないこと確認
    expect(find("#edit-schedule-sub")).to have_content "スケジュール未設定"
  end
end
