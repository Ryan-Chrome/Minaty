require "rails_helper"

RSpec.describe "Registration", type: :system, js: true do
  let!(:dept) { create(:human_resources_dept) }
  let!(:admin_user) { create(:admin_user, department_id: dept.id) }
  let!(:user) { create(:user, department_id: dept.id) }

  before { login(admin_user) }

  it "新規ユーザー作成動作確認" do
    # ユーザー管理画面でテストユーザーがいないこと確認
    visit users_path
    expect(page).not_to have_content "テストユーザー"
    # ユーザー新規登録フォーム表示
    visit new_user_registration_path
    expect(page).to have_css "#user-new-form"
    # フォーム空入力、送信
    expect(page).not_to have_css ".field_with_errors"
    click_on "登録"
    expect(page).to have_css ".field_with_errors"
    expect(page).not_to have_css "#users-table-container"
    # フォーム入力、送信
    fill_in "名前", with: "テストユーザー"
    fill_in "フリガナ", with: "テストユーザー"
    select "人事部", from: "部署"
    fill_in "メールアドレス", with: "create_test@email.com"
    fill_in "user_password", with: "foobar"
    fill_in "user_password_confirmation", with: "foobar"
    click_on "登録"
    # ユーザー管理画面表示確認
    expect(page).to have_css "#users-table-container"
    expect(page).to have_content "テストユーザー"
  end

  it "ユーザー編集動作確認" do
    # ダッシュボードでユーザー名確認
    visit user_path(admin_user.public_uid)
    expect(page).to have_content admin_user.name
    expect(page).not_to have_content "edit_user"
    # ユーザー編集フォーム表示
    visit edit_other_user_registration_path(admin_user.public_uid)
    expect(page).to have_css "#user-edit-form"
    # フォーム空入力、送信
    expect(page).not_to have_css ".field_with_errors"
    click_on "更新"
    expect(page).to have_css ".field_with_errors"
    expect(page).not_to have_css "#user-container"
    # フォーム入力、送信
    fill_in "ユーザー名", with: "edit_user"
    fill_in "user_current_password", with: admin_user.password
    click_on "更新"
    # 編集したユーザーのダッシュボード表示確認
    expect(page).to have_css "#user-container"
    expect(page).not_to have_content admin_user.name
    expect(page).to have_content "edit_user"
  end

  it "ユーザー削除確認" do
    # ユーザー管理画面でユーザーが存在すること確認
    visit users_path
    expect(find("#users-table-container")).to have_content user.name
    # ユーザー編集フォーム表示
    visit edit_other_user_registration_path(user.public_uid)
    # 管理者パスワード入力しないで削除ボタンクリック
    click_on "削除"
    expect(page.accept_confirm).to eq "このユーザーに関する情報は全て削除されます。実行しますか？"
    expect(page).not_to have_css "#users-table-container"
    # 管理者パスワード入力して削除ボタンクリック
    fill_in "current_password", with: admin_user.password
    click_on "削除"
    expect(page.accept_confirm).to eq "このユーザーに関する情報は全て削除されます。実行しますか？"
    # ユーザー管理画面表示確認
    expect(page).to have_css "#users-table-container"
    expect(find("#users-table-container")).not_to have_content user.name
  end
end
