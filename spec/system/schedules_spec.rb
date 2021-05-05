require 'rails_helper'

RSpec.describe "Schedule", type: :system, js: true do

    let!(:user){ create(:user) }

    # スケジュール作成
    describe "Create" do
        before do
            login(user)
        end

        # 作成完了からホーム画面にスケージュール追加されていること確認
        it "Completes" do
            # 追加スケジュール日付選択フォーム表示
            click_on "add-schedule-btn"
            # 追加スケジュール詳細入力画面表示
            click_button "次へ"

            # フォーム記入
            fill_in "内容", with: "テスト会議"
            select "10", from: "schedule_start_at_4i"
            select "00", from: "schedule_start_at_5i"
            select "15", from: "schedule_finish_at_4i"
            select "30", from: "schedule_finish_at_5i"
            click_button "登録"

            # 追加完了メッセージ & スケジュールが追加されている
            expect(page).to have_content "スケジュールを追加しました。"
            expect(page).to have_selector "#add-schedule-name-0", text: "テスト会議"
            expect(page).to have_selector "#add-schedule-time-0", text: "10:00~15:30"

            # フォーム閉 & ホーム画面のスケジュール表に追加されている
            find("#add-schedule-next-close").click
            expect(page).to have_selector "#schedule-name-0", text: "テスト会議"
            expect(page).to have_selector "#time-0", text: "10:00~15:30"
        end

        # 作成失敗から戻るボタン動作確認まで
        it "Unfinished" do
            # 追加スケジュール詳細入力しない
            click_on "add-schedule-btn"
            click_button "次へ"
            click_button "登録"

            # エラーメッセージが表示されていること
            expect(page).to have_content "処理に失敗しました。"

            # 日付選択フォームへ戻ること
            find("#add-schedule-next-back").click
            expect(page).to have_selector "#add-schedule-data"
            
            # ホーム画面に戻ること
            find("#add-schedule-data-close").click
            expect(page).not_to have_selector "#add-schedule-data"
        end
    end

    # スケジュール編集
    describe "Edit" do
        let!(:schedule){ create(:system_schedule, user_id: user.id) }
        before do
            login(user)
        end

        # 編集するスケジュール選択・完了から
        # ホーム画面に変更された内容が反映されているか確認まで
        it "Completes" do
            # 編集スケジュール選択画面表示
            click_on "edit-schedule-btn"
            expect(page).to have_selector "#edit-schedule-main"

            # 編集スケジュール選択 & 編集フォーム表示確認
            first(".edit-schedule-0").click
            expect(page).to have_selector "#edit-schedule-next-main"

            # フォーム記入
            fill_in "内容", with: "テスト会議編集済"
            select "15", from: "schedule_edit_start_at_4i"
            select "10", from: "schedule_edit_start_at_5i"
            select "20", from: "schedule_edit_finish_at_4i"
            select "00", from: "schedule_edit_finish_at_5i"
            click_button "変更"

            # 編集スケジュール選択画面へ移動 & 編集成功メッセージ表示
            expect(page).to have_selector "#edit-schedule-main"
            expect(page).to have_content "スケジュールを編集しました。"

            # 編集スケジュール選択画面のスケジュールが変更されていること
            expect(page).to have_selector "#edit-schedule-name-0", text: "テスト会議編集済"
            expect(page).to have_selector "#edit-time-0", text: "15:10~20:00"
    
            # 編集スケジュール選択画面閉 & ホームのスケジュールが変更されていること
            find("#edit-schedule-close").click
            expect(page).to have_selector "#schedule-name-0", text: "テスト会議編集済"
            expect(page).to have_selector "#time-0", text: "15:10~20:00"
        end

        # 編集するスケジュール選択・失敗から
        # ホーム画面に戻るまで
        it "Unfinished" do
            # 編集スケジュール選択画面表示
            click_on "edit-schedule-btn"

            # 編集スケジュール選択
            first(".edit-schedule-0").click

            # 内容を未入力にする
            fill_in "内容", with: ""
            click_button "変更"

            # 編集スケジュール選択画面に移動しない & 編集失敗メッセージ表示
            expect(page).to have_selector "#edit-schedule-next-main"
            expect(page).to have_content "編集に失敗しました。"
            
            # 開始時間と終了時刻を不正な値にする
            fill_in "内容", with: "テスト会議編集済"
            select "20", from: "schedule_edit_start_at_4i"
            select "10", from: "schedule_edit_start_at_5i"
            select "10", from: "schedule_edit_finish_at_4i"
            select "00", from: "schedule_edit_finish_at_5i"
            click_button "変更"

            # 編集失敗メッセージ表示
            expect(page).to have_content "編集に失敗しました。"

            # 編集スケジュール選択画面へ戻る
            find("#edit-schedule-next-back").click
            expect(page).not_to have_selector "#edit-schedule-next-main"

            # ホーム画面へ戻る
            find("#edit-schedule-close").click
            expect(page).not_to have_selector "#edit-schedule-main"
        end
    end

    # スケジュール削除
    describe "Destroy" do
        let!(:schedule){ create(:system_schedule, user_id: user.id) }
        before do
            login(user)
        end

        # 編集するスケジュール選択・削除から
        # ホーム画面に変更された内容が反映されているか確認まで
        it "Completes" do
            # ホーム画面にスケジュールがあるか
            expect(page).to have_selector "#schedule-name-0", text: "テスト会議"
            expect(page).to have_selector "#time-0", text: "10:00~15:30"

            # 編集スケジュール選択画面表示
            # スケジュール選択時のスケジュールに削除するスケジュールがあるか
            click_on "edit-schedule-btn"
            expect(page).to have_selector "#edit-schedule-name-0", text: "テスト会議"
            expect(page).to have_selector "#edit-time-0", text: "10:00~15:30"

            # 編集スケジュール選択
            first(".edit-schedule-0").click

            # 削除ボタン
            click_on "削除"

            # 編集スケジュール選択画面に戻ること・削除成功メッセージ表示されていること
            expect(page).to have_selector "#edit-schedule-main"
            expect(page).to have_content "スケジュールを削除しました。"


            # 編集スケジュール選択画面のスケジュールが削除されていること
            expect(page).not_to have_selector "#edit-schedule-name-0", text: "テスト会議"
            expect(page).not_to have_selector "#edit-time-0", text: "10:00~15:30"
    
            # 編集スケジュール選択画面閉 & ホームのスケジュールが削除されていること
            find("#edit-schedule-close").click
            expect(page).not_to have_selector "#schedule-name-0", text: "テスト会議"
            expect(page).not_to have_selector "#time-0", text: "10:00~15:30"
        end
    end

end