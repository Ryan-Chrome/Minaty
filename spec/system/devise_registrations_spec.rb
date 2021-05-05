require 'rails_helper' 

RSpec.describe "Registration", type: :system, js: true do

    let!(:admin_user){ create(:admin_user) }

    # 新規ユーザー作成画面から登録完了ホーム画面まで
    it "Completes user sign_up" do
        login(admin_user)
        visit new_user_registration_path

        fill_in "名前", with: "テストユーザー"
        fill_in "フリガナ", with: "テストユーザー"
        select "人事部", from: "所属"
        fill_in "メールアドレス", with: "test@email.com"
        fill_in "user_password", with: "foobar"
        fill_in "user_password_confirmation", with: "foobar"
        click_button "登録"

        expect(find("#management-user-container")).to have_content "ユーザーリスト"
    end

    # 新規ユーザー作成失敗
    it "Unfinished user sign_up" do
        login(admin_user)
        visit new_user_registration_path

        click_button "登録"

        expect(page).not_to have_content "ユーザーリスト"
    end

end