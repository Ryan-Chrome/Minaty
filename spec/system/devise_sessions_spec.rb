require "rails_helper"

RSpec.describe "Session", type: :system, js: true do
  let!(:dept) { create(:human_resources_dept) }
  let!(:user) { create(:user, department_id: dept.id) }

  it "ログイン動作からログアウト動作確認" do
    # ログインページ表示
    visit new_user_session_path
    # フォーム空入力、送信
    click_on "ログイン"
    # エラーメッセージ確認
    expect(page).to have_content "Eメールまたはパスワードが違います。"
    # フォーム入力、送信
    fill_in "メールアドレス", with: "test@email.com"
    fill_in "パスワード", with: "foobar"
    click_button "ログイン"
    # ログインしたこと確認
    expect(page).to have_css "#sidebar-btn-trigger"
    find("#sidebar-btn-trigger").click
    # ログアウトボタンクリック
    click_on "ログアウト"
    # ログアウトしたこと確認
    expect(page).to have_css ".not-login-home"
    expect(page).not_to have_css "#sidebar-btn-trigger"
  end
end
