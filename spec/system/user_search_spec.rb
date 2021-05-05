require 'rails_helper'

RSpec.describe "UserSearch", type: :system, js: true do

    let!(:user){ create(:user) }
    let!(:other_user){ create(:other_user) }
    let!(:therd_user){ create(:therd_user) }

    # ユーザー検索
    describe "Search" do
        before do
            login(user)
        end

        # 他ユーザー2人の検索 -> ユーザー詳細表示まで
        it "search other_user" do
            # 検索ボックスが表示されてないこと確認
            expect(page).not_to have_selector "#user-search-box"

            # ユーザー検索ボタン表示
            find("#user-search-btn").click

            # 検索ボックスが表示されていること確認
            expect(page).to have_selector "#user-search-box"

            # フォーム入力
            fill_in "名前", with: "other_user"
            select "人事部", from: "department"
            click_button "検索"

            # 検索ボックスが閉じて、検索結果が表示されること
            expect(page).not_to have_selector "#user-search-box"
            expect(page).to have_selector "#user-search-response"

            # other_userのみが検索結果に表示されること
            expect(find("#search-user-list")).to have_content "other_user"
            expect(find("#search-user-list")).not_to have_content "therd_user"

            # 検索結果画面の戻るボタンクリック
            find("#user-search-response-back-btn").click

            # 検索結果画面が閉じて検索ボックスが表示されること
            expect(page).not_to have_selector "#user-search-response"
            expect(page).to have_selector "#user-search-box"

            # フォーム入力
            fill_in "名前", with: ""
            select "人事部", from: "department"
            click_button "検索"

            # other_userをクリック
            find("#search-user-list a:nth-child(1)").click

            # 検索結果が閉じて、other_userのユーザー詳細画面が表示されること
            expect(page).not_to have_selector "#user-search-response"
            expect(page).to have_selector "#user-content"
            expect(find("#user-left-content h6")).to have_content "other_user"

            # 戻るボタンクリック
            find("#user-content-back-btn").click

            # ユーザー詳細画面が閉じて、検索結果画面が教示されること
            expect(page).not_to have_selector "#user-content"
            expect(page).to have_selector "#user-search-response"

            # therd_userをクリック
            find("#search-user-list a:nth-child(2)").click

            # 検索結果が閉じて、therd_userのユーザー表示画面が表示されること
            expect(page).not_to have_selector "#user-search-response"
            expect(page).to have_selector "#user-content"
            expect(find("#user-left-content h6")).to have_content "therd_user"

            # ユーザー詳細画面の閉じるボタンを押してユーザー詳細画面が消えてることを確認
            find("#user-content-close").click
            expect(page).not_to have_selector "#user-content"
        end
    end

end