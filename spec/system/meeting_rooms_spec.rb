require 'rails_helper'

RSpec.describe "MeetingRoom", type: :system, js: true do

    let!(:user){ create(:user) }
    let!(:other_user){ create(:other_user) }
    let!(:therd_user){ create(:therd_user) }
    
    # ルーム作成
    describe "Create" do
        # ミーティングルーム作成からミーティングロビー確認まで
        it "Complates" do
            # ルーム予約メッセージ確認用ユーザーA、ログイン
            using_session :userA do
                login(other_user)
            end

            # ルーム予約メッセージ確認用ユーザーB、ログイン
            using_session :userB do
                login(therd_user)
            end

            # メインユーザー ログインからルーム予約ユーザー操作
            login(user)
            # ミーティングロビーへ
            find("#sidebar-btn-trigger").click
            click_on "MEETING"
            expect(page).to have_selector "#rooms-container"

            # まだミーティングルームがないことを確認
            expect(page).to have_selector "#no-rooms"

            # ルーム新規登録フォームへ
            find("#new-room-link").click
            expect(page).to have_selector "#meeting-new-form"

            # フォーム入力
            fill_in "ミーティング内容", with: "テスト会議"
            fill_in "meeting_room_meeting_date", with: Date.today
            select "10", from: "meeting_room_start_at_4i"
            select "30", from: "meeting_room_start_at_5i"
            select "23", from: "meeting_room_finish_at_4i"
            select "50", from: "meeting_room_finish_at_5i"

            # ミーティングにエントリーさせるユーザー選択
            find("#entry-select-group-0").click
            find("#entry-select-list-0 li:nth-child(1)").click
            find("#entry-select-list-0 li:nth-child(2)").click

            # 選択したユーザーが選択済みのリストに追加されていること
            expect(find("#selected-users")).to have_content "other_user"
            expect(find("#selected-users")).to have_content "therd_user"

            # 作成ボタンクリック
            click_button "ルーム作成"

            # ミーティングロビーにリダイレクトされること、作成したルームが表示されていること
            expect(page).to have_selector "#rooms-container"
            expect(page).to have_selector ".room-content"
            

            # ユーザーAのホーム画面にルーム予約メッセージが送られたか
            using_session :userA do
                expect(first(".message-content")).to have_content "ミーティングルームを予約しました。"
            end

            # ユーザーBのホーム画面にルーム予約メッセージが送られたか
            using_session :userB do
                expect(first(".message-content")).to have_content "ミーティングルームを予約しました。"
            end
        end

        # ミーティングルーム作成失敗
        it "Unfinished" do
            # ログイン
            login(user)

            # ミーティングルームへ
            find("#sidebar-btn-trigger").click
            click_on "MEETING"
        
            # ルーム新規作成リンククリック
            find("#new-room-link").click

            # フォーム入力(内容未入力)
            fill_in "ミーティング内容", with: ""
            fill_in "meeting_room_meeting_date", with: Date.today
            select "10", from: "meeting_room_start_at_4i"
            select "30", from: "meeting_room_start_at_5i"
            select "12", from: "meeting_room_finish_at_4i"
            select "50", from: "meeting_room_finish_at_5i"
            find("#entry-select-group-0").click
            find("#entry-select-list-0 li:nth-child(1)").click
            find("#entry-select-list-0 li:nth-child(2)").click
            click_button "ルーム作成"

            # エラーになっているか
            expect(all(".field_with_errors").count).to eq 2

            # フォーム入力(日付未入力)
            fill_in "ミーティング内容", with: "テストルーム"
            fill_in "meeting_room_meeting_date", with: ""
            select "10", from: "meeting_room_start_at_4i"
            select "30", from: "meeting_room_start_at_5i"
            select "12", from: "meeting_room_finish_at_4i"
            select "50", from: "meeting_room_finish_at_5i"
            find("#entry-select-group-0").click
            find("#entry-select-list-0 li:nth-child(1)").click
            find("#entry-select-list-0 li:nth-child(2)").click
            click_button "ルーム作成"

            expect(all(".field_with_errors").count).to eq 2

            # フォーム入力(開始時間を終了時間より遅く入力)
            fill_in "ミーティング内容", with: "テストルーム"
            fill_in "meeting_room_meeting_date", with: Date.today
            select "20", from: "meeting_room_start_at_4i"
            select "30", from: "meeting_room_start_at_5i"
            select "12", from: "meeting_room_finish_at_4i"
            select "50", from: "meeting_room_finish_at_5i"
            find("#entry-select-group-0").click
            find("#entry-select-list-0 li:nth-child(1)").click
            find("#entry-select-list-0 li:nth-child(2)").click
            click_button "ルーム作成"

            expect(all(".field_with_errors").count).to eq 2

            # フォーム入力(ユーザー未選択)
            fill_in "ミーティング内容", with: "テストルーム"
            fill_in "meeting_room_meeting_date", with: Date.today
            select "10", from: "meeting_room_start_at_4i"
            select "30", from: "meeting_room_start_at_5i"
            select "12", from: "meeting_room_finish_at_4i"
            select "50", from: "meeting_room_finish_at_5i"
            click_button "ルーム作成"

            expect(page).to have_selector ".entries-error"
        end
    end

    # ルームからユーザーを招待
    describe "Invitation" do
        let!(:meeting_room){ create(:meeting_room) }
        let!(:entry){ meeting_room.entries.create(user_id: user.id) }
        let!(:other_user_entry){ meeting_room.entries.create(user_id: other_user.id) }

        # 作成済みルーム入室からtherd_user招待
        it "Complates" do
            # ルーム内の変化確認用ユーザーA、ログイン
            using_session :userA do
                login(other_user)

                # 作成済みルームへ
                visit meeting_room_path(meeting_room.public_uid)

                # ルームのユーザーリストを開いてtherd_userがいないことを確認
                find("#room-users").click
                expect(find("#room-users-container")).not_to have_content "therd_user"
            end

            # 招待メッセージ確認用ユーザーB、ログイン
            using_session :userB do
                login(therd_user)
            end

            # メインユーザー ログインから招待操作
            login(user)
            # 作成済みルームへ
            visit meeting_room_path(meeting_room.public_uid)

            # ルームのユーザーリストを開いてtherd_userがいないことを確認
            find("#room-users").click
            expect(find("#room-users-container")).not_to have_content "therd_user"

            # 招待リストを開いてtherd_userを招待
            find("#room-invitation").click
            find("#invitation-user-#{therd_user.public_uid} input").click

            # 招待した後招待リストからtherd_userが消えているか確認
            expect(find("#room-invitation-container")).not_to have_selector "#invitation-user-#{therd_user.public_uid}"

            # ルームのユーザーリストを開いてtherd_userが追加されているか確認
            find("#room-users").click
            expect(find("#room-users-container")).to have_content "therd_user"

            # 招待メッセージを送ったことを確認
            visit root_path
            expect(first(".message-content")).to have_content "ルームに招待されました。"

            # ユーザー１が招待した後の確認
            using_session :userA do
                # ルームのユーザーリストにtherd_userが追加されているか確認
                expect(find("#room-users-container")).to have_content "therd_user"

                # 招待リストを開いてtherd_userがないことを確認
                find("#room-invitation").click
                expect(find("#room-invitation-container")).not_to have_selector "#invitation-user-#{therd_user.public_uid}"
            end

            # 招待メッセージが送られたことを確認
            using_session :userB do
                expect(first(".message-content")).to have_content "ルームに招待されました。"
            end
        end
    end

    # ルーム内メッセージ
    describe "Message" do
        let!(:meeting_room){ create(:meeting_room) }
        let!(:entry){ meeting_room.entries.create(user_id: user.id) }
        let!(:other_user_entry){ meeting_room.entries.create(user_id: other_user.id) }

        # ルーム内メッセージ送信から確認まで
        it "Complates" do
            # ルームメッセージ確認ユーザーA、ログインからルームメッセージコンテナ開く
            using_session :userA do
                login(other_user)
                visit meeting_room_path(meeting_room.public_uid)
                find("#room-message").click
            end

            # メインユーザー、ユーザーAと同じルームへ、メッセージ送信
            login(user)
            visit meeting_room_path(meeting_room.public_uid)
            find("#room-message").click
            fill_in "room-message-textarea", with: "テストテキスト"
            click_button "送信"

            # 送信したメッセージが追加されていること
            expect(find("#messages")).to have_content "テストテキスト"
            expect(find("#messages")).to have_content "#{user.name}"

            # ユーザー１が送信したメッセージが表示されているか確認、その後メッセージ送信
            using_session :userA do
                expect(find("#messages")).to have_content "テストテキスト"

                fill_in "room-message-textarea", with: "テストテキスト２"
                click_button "送信"

                # 送信したメッセージが追加されていること
                expect(find("#messages")).to have_content "テストテキスト２"
                expect(find("#messages")).to have_content "#{other_user.name}"
            end

            # ユーザー２が送信したメッセージが表示されているか確認
            expect(find("#messages")).to have_content "テストテキスト２"
            expect(find("#messages")).to have_content "#{other_user.name}"
        end

        # ルーム内メッセージ送信失敗時、アラートが出ること確認
        it "Unfinished" do
            login(user)
            visit meeting_room_path(meeting_room.public_uid)

            # メッセージコンテナを開いて、400文字以上で送信
            find("#room-message").click
            fill_in "room-message-textarea", with: "#{"a" * 500}"
            click_button "送信"

            # 送信失敗ダイアログが出ること
            expect(page.dismiss_prompt).to eq "メッセージは400文字以内で入力してください"

            # 空入力で送信
            fill_in "room-message-textarea", with: ""
            click_button "送信"

            # 送信失敗ダイアログが出ること
            expect(page.dismiss_prompt).to eq "メッセージを入力してください"
        end
    end

    # ルームからルーム外部へメッセージ送信
    describe "GeneralMessage" do
        let!(:meeting_room){ create(:meeting_room) }
        let!(:entry){ meeting_room.entries.create(user_id: user.id) }

        # 外部メッセージ送信先選択後からメッセージ送信からルームに参加しているユーザーへのメッセージ送信
        it "Complates" do
            # メッセージ受信確認用ユーザーA、ログインからHOME画面待機
            using_session :userA do
                login(other_user)
            end

            # メインユーザーログイン
            login(user)
            visit meeting_room_path(meeting_room.public_uid)
            find("#outside-send-message-list").click
            first("#general-message-user-list .group-container").click
            first(".select-user-#{other_user.public_uid}").click

            fill_in "general-message-textarea", with: "テストテキスト"
            click_button "送信"

            expect(find("#messages")).to have_content "テストテキスト"
            expect(find("#messages")).to have_content "(外部メッセージ)"

            # ユーザーAでメッセージ確認後、ルーム外部からメッセージ送信
            using_session :userA do
                expect(find("#chat-container")).to have_content "テストテキスト"

                # 送信先をメインユーザーに設定
                find("#add-send-user").click
                first("#send-list .group-container").click
                first("#send-list .user-selector-#{user.public_uid}").click
                click_button "完了"

                # 宛先欄に追加されているか
                expect(find("#chat-send-user-list")).to have_selector "#send-selected-user-#{user.public_uid}"

                # チャット入力、送信
                fill_in "chat-text-area", with: "外部からのテキスト"
                click_button "送信"
            end

            # ルームにいるメインユーザーにメッセージが表示されているか確認
            expect(first("#messages .message-content.other")).to have_content "外部からのテキスト"
        end

        # 外部へのメッセージ送信失敗時、アラートが出ること確認
        it "Unfinished" do
            login(user)
            visit meeting_room_path(meeting_room.public_uid)

            # 外部メッセージコンテナを開く
            find("#outside-send-message-list").click

            # 空送信
            click_button "送信"
            expect(page.dismiss_prompt).to eq "メッセージの文字数か、送信先設定に不備があります。"

            # メッセージだけ入力して送信
            fill_in "general-message-textarea", with: "テストテキスト"
            click_button "送信"
            expect(page.dismiss_prompt).to eq "メッセージの文字数か、送信先設定に不備があります。"

            # 送信先設定だけして送信
            fill_in "general-message-textarea", with: ""
            first("#general-message-user-list .group-container").click
            first(".select-user-#{other_user.public_uid}").click
            click_button "送信"
            expect(page.dismiss_prompt).to eq "メッセージの文字数か、送信先設定に不備があります。"
        end
    end

end