require "rails_helper"

RSpec.describe "Attendance", type: :system, js: true do
  let!(:dept) { create(:human_resources_dept) }
  let!(:admin_user) { create(:admin_user, department_id: dept.id) }
  let!(:user) { create(:user, department_id: dept.id) }

  before { login(admin_user) }
  
  it "出勤打刻から退勤打刻までの動作確認" do
    find("#sidebar-btn-trigger").click
    # 出勤ボタンが存在し退勤ボタンがないこと確認
    expect(find("#attendance-content")).to have_css "a.arrive"
    expect(find("#attendance-content")).not_to have_css "a.leave"
    # 出勤ボタンクリックからダイアログ確認
    click_on "出勤"
    expect(page.accept_confirm).to eq "出勤時刻を打刻します"
    # 出勤ボタンが消えて出勤時刻が表示され退勤ボタンが表示
    expect(find("#attendance-content")).not_to have_css "a.arrive"
    expect(find("#attendance-content")).to have_content "出勤時間"
    expect(find("#attendance-content")).to have_css "a.leave"
    # 退勤ボタンクリックからダイアログ確認
    click_on "退勤"
    expect(page.accept_confirm).to eq "退勤時刻を打刻します"
    # 退勤ボタンが消えて退勤時刻が表示
    expect(find("#attendance-content")).not_to have_css "a.leave"
    expect(find("#attendance-content")).to have_content "退勤時間"
  end

  it "勤怠一覧検索動作確認" do
    visit attendances_path
    # 全てのユーザーが表示されてることを確認
    expect(find("#myTable")).to have_content "#{admin_user.name}"
    expect(find("#myTable")).to have_content "#{user.name}"
    # 検索フォーム入力
    fill_in "search-name", with: "#{admin_user.name}"
    click_on "検索"
    # 検索したユーザーのみ表示されてること確認
    expect(find("#myTable")).to have_content "#{admin_user.name}"
    expect(find("#myTable")).not_to have_content "#{user.name}"
  end

  it "CSVファイルダウンロード動作確認" do
    visit attendances_path
    # フォームが表示されてないこと確認
    expect(find("#csv-form-container")).not_to have_css "#download-form"
    # フォーム表示から正しい入力
    find("#download-header").click
    fill_in "start_date", with: Date.today
    fill_in "finish_date", with: Date.today + 2.day
    click_on "download-btn"
    sleep 0.1
    # ファイルがダウンロードされたことを確認
    expect(download_content).to include "admin_user"
    # ファイル削除
    clear_downloads
    # 正しくない内容を入力
    fill_in "start_date", with: Date.today
    fill_in "finish_date", with: Date.today - 2.day
    click_on "download-btn"
    # ファイルがダウンロードされないことを確認
    expect(download_content).to be_falsey
    # エラーメッセージダイアログが表示されること
    expect(page.accept_confirm).to eq "フォームに不備があります"
  end
end
