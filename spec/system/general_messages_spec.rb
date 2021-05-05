require 'rails_helper'

RSpec.describe "GeneralMessage", type: :system, js: true do

    let!(:user){ create(:user) }
    let!(:other_user){ create(:other_user) }
    let!(:therd_user){ create(:therd_user) }

    # Homeのチャットフォームから送信
    describe "MultipleCreate" do
        # メッセージ送信
        # 自分のチャットコンテナに送信内容が追加されていること
        # 送信先のユーザーのチャットコンテナに送信したメッセージが表示されていること
        it "Completes" do
            # メッセージ確認用ユーザーA、ログイン
            using_session :userA do
                login(other_user)
            end

            # メッセージ確認用ユーザーB、ログイン
            using_session :userB do
                login(therd_user)
            end

            # メインユーザー ログインからメッセージ送信
            login(user)
            # 宛先追加フォーム開く
            find("#add-send-user").click
            expect(page).to have_selector "#send-user-container"

            # 送信先ユーザー選択
            first("#send-list .group-container").click
            first("#send-list .user-selector-#{other_user.public_uid}").click
            first("#send-list .user-selector-#{therd_user.public_uid}").click
            click_button "完了"

            # 宛先欄に追加されているか
            expect(find("#chat-send-user-list")).to have_selector "#send-selected-user-#{other_user.public_uid}"
            expect(find("#chat-send-user-list")).to have_selector "#send-selected-user-#{therd_user.public_uid}"

            # チャット内容入力、送信
            fill_in "chat-text-area", with: "テストテキスト"
            click_button "送信"

            # 自分のチャットフォームにメッセージが追加されたか
            expect(first(".message-content .message-user-name")).to have_content "他1人"
            expect(first(".message-content .message")).to have_content "テストテキスト"

            # ユーザーAでユーザー１が送信したメッセージが表示されているか
            using_session :userA do
                expect(first(".message-content .message-user-name")).to have_content "example"
                expect(first(".message-content .message")).to have_content "テストテキスト"
            end
            
            # ユーザーBでユーザー１か送信したメッセージが表示されているか
            using_session :userB do
                expect(first(".message-content .message-user-name")).to have_content "example"
                expect(first(".message-content .message")).to have_content "テストテキスト"
            end
        end

        # メッセージ送信失敗
        it "Unfinished" do
            # ログイン
            login(user)

            # チャット内容入力、送信先設定しないで送信
            fill_in "chat-text-area", with: "テストテキスト"
            click_button "送信"

            # 送信失敗ダイアログ表示
            expect(page.dismiss_prompt).to eq "送信先もしくは内容に不備があります。"

            # チャット未入力、送信先設定済で送信
            find("#add-send-user").click
            expect(page).to have_selector "#send-user-container"
            first("#send-list .group-container").click
            first("#send-list .user-selector-#{other_user.public_uid}").click
            first("#send-list .user-selector-#{therd_user.public_uid}").click
            click_button "完了"
            fill_in "chat-text-area", with: ""
            click_button "送信"

            # 送信失敗ダイアログ表示
            expect(page.dismiss_prompt).to eq "送信先もしくは内容に不備があります。"
        end
    end

    # ユーザー詳細から送信
    describe "Create" do
        # ユーザー詳細画面からメッセージ送信成功からメッセージ確認まで
        it "Completes" do
            # ユーザー詳細メッセージ確認用ユーザーA、ログインからユーザー詳細まで
            using_session :userA do
                login(other_user)
                find("#user-list li:nth-child(2)").click_on
                find("#user-list.next li:nth-child(1)").click_on
            end

            # メインユーザーログインからユーザーAの詳細画面からメッセージ送信操作
            login(user)

            # ユーザーコンテナ other_userの所属グループをクリック
            find("#user-list li:nth-child(2)").click_on

            # other_userクリック 詳細画面表示
            find("#user-list.next li:nth-child(1)").click_on

            # チャットフォームに入力・送信
            fill_in "user-content-chat-text-area", with: "テストテキスト"
            click_button "chat-send-btn"

            # ユーザー詳細画面に送信したメッセージが表示されていること
            expect(first("#chat-log .message-content")).to have_content "テストテキスト"

            # ユーザー詳細画面閉・ホームのチャットコンテナに送信したメッセージが表示されていること
            find("#user-content-close").click
            expect(first("#chat-content .message-content")).to have_content "テストテキスト"

            using_session :userA do
                # メインユーザー詳細画面で送信されたメッセージが表示されていること
                expect(first("#chat-log .message-content")).to have_content "テストテキスト"

                # メインユーザーの詳細画面を閉じてホームのメッセージコンテナにメッセージが追加されているか
                find("#user-content-close").click
                expect(first("#chat-content .message-content")).to have_content "テストテキスト"
            end
        end

        # ユーザー詳細画面からメッセージ送信失敗
        it "Unfinished" do
            # ログイン
            login(user)

            # ユーザーコンテナ other_userの所属グループをクリック
            find("#user-list li:nth-child(2)").click_on

            # other_userをクリック 詳細画面表示
            find("#user-list.next li:nth-child(1)").click_on

            # チャットフォーム未入力で送信
            click_button "chat-send-btn"

            # 送信失敗ダイアログ表示
            expect(page.dismiss_prompt).to eq "送信内容に不備があります。"
        end
    end
end