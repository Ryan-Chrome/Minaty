require 'rails_helper'

RSpec.describe "Session", type: :system, js: true do

    let!(:user){ create(:user) }

    # ログイン画面からログイン完了~ログアウトまで
    it "Completes user login" do
        visit new_user_session_path

        fill_in "Eメール", with: "test@email.com"
        fill_in "パスワード", with: "foobar"
        click_button "ログイン"

        expect(page).to have_selector "#sidebar-btn-trigger"
        find("#sidebar-btn-trigger").click
        click_on "LOGOUT"

        expect(page).to have_selector ".not-login-home"
        expect(page).not_to have_selector "#sidebar-btn-trigger"
    end

    # ログイン画面からログイン失敗まで
    it "Unfinished user login" do
        visit new_user_session_path

        fill_in "Eメール", with: "invalid@email.com"
        fill_in "パスワード", with: "invalid"

        click_button "ログイン"

        expect(page).to have_content "Eメールまたはパスワードが違います。"
        expect(page).not_to have_selector "#sidebar-btn-trigger"
    end

end