require 'rails_helper' 

RSpec.describe "ContactGroup", type: :system, js: true do

    let!(:user){ create(:user) }
    let!(:other_user){ create(:other_user) }
    let!(:therd_user){ create(:therd_user) }

    # コンタクトグループ作成
    describe "Create" do
        before do
            login(user)
        end

        # 新規グループ作成からホーム画面に戻るまで
        it "Completes" do
            # 新規グループ作成フォーム開く
            find("#new-group-btn").click
            expect(page).to have_selector "#new-group-main-form"

            # 追加するユーザー選択
            first(".group-container").click
            first(".user-selector-#{other_user.public_uid}").click
            first(".user-selector-#{therd_user.public_uid}").click

            # グループ名入力
            fill_in "グループ名", with: "テストグループ"
            click_button "作成"

            # 追加完了メッセージ & 追加ユーザーリストにグループが追加されていること
            expect(page).to have_content "グループを登録しました。"
            expect(page).to have_selector "#new-group-main-form"
            expect(find("#new-group-user-list")).to have_content "テストグループ"
            
            # フォーム閉 & ホーム画面のグループコンテナに表示されていること
            find("#new-group-close").click
            expect(find("#user-list")).to have_content "テストグループ"
        end

        # 新規グループ作成失敗
        it "Unfinished" do
            # 新規グループ作成フォーム開く
            find("#new-group-btn").click
            
            # 追加するユーザーを選択しないで作成
            fill_in "グループ名", with: "テストグループ"
            click_button "作成"

            # 追加失敗メッセージ
            expect(page).to have_content "処理に失敗しました。"
            expect(find("#new-group-user-list")).not_to have_content "テストグループ"

            # 追加するユーザーを選択後、グループ名を入力せず作成
            first(".group-container").click
            first(".user-selector-#{other_user.public_uid}").click
            first(".user-selector-#{other_user.public_uid}").click
            click_button "作成"

            # 追加失敗メッセージ
            expect(page).to have_content "処理に失敗しました。"
        end
    end

    # コンタクトグループ削除
    describe "Destroy" do
        let!(:contact_group){ user.contact_groups.create(name: "テストグループ") }
        let!(:group_relation_1){ contact_group.contact_group_relations.create(user_id: other_user.id) }
        let!(:group_relation_2){ contact_group.contact_group_relations.create(user_id: therd_user.id) }
        before do
            login(user)
        end

        # 作成済みのテストグループ削除
        it "Completes" do
            # グループコンテナの作成済グループクリック
            find("#side-group-id-#{contact_group.id}").click_on

            # 削除ボタンクリック & 確認ダイアログ OK
            page.accept_confirm do
                find("#group-delete-link").click
            end

            # 削除完了ダイアログ内容確認
            expect(page.dismiss_prompt).to eq "テストグループを削除しました。" 

            # グループが削除されていること
            expect(page).not_to have_selector "#side-group-id-#{contact_group.id}"
        end
    end
end