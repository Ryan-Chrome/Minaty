require "rails_helper"

RSpec.describe "UserSearch", type: :system, js: true do
  let!(:dept) { create(:human_resources_dept) }
  let!(:user) { create(:user, department_id: dept.id) }
  let!(:other_user) { create(:other_user, department_id: dept.id) }
  let!(:admin_user) { create(:admin_user, department_id: dept.id) }

  before { login(admin_user) }

  it "ユーザー検索モーダル動作からユーザー詳細モーダル動作確認" do
    # ユーザー検索ボックスフォーム表示
    expect(page).not_to have_css "#user-search-box"
    click_on "user-search-btn"
    expect(page).to have_css "#user-search-box"
    # 存在しないユーザー名を入力
    fill_in "名前", with: "invalid_user"
    click_on "検索"
    # 検索結果に該当するユーザーが存在しないこと確認
    expect(page).not_to have_css "#user-search-box"
    expect(page).to have_css "#user-search-response"
    expect(find("#user-search-response")).to have_content "該当するユーザーが\n存在しません"
    # 検索ボックスに戻って存在するユーザー名を入力
    find("#user-search-response-back-btn").click
    expect(page).not_to have_css "#user-search-response"
    expect(page).to have_css "#user-search-box"
    fill_in "名前", with: "#{other_user.name}"
    select "#{dept.name}", from: "department"
    click_on "検索"
    # 検索結果に検索したユーザーが存在すること
    expect(page).to have_css "#user-search-response"
    expect(find("#user-search-response")).to have_content "#{other_user.name}"
    # 検索結果からユーザー詳細モーダル表示
    expect(page).not_to have_css "#user-content"
    first("#search-user-list a").click
    expect(page).to have_css "#user-content"
    expect(find("#user-content")).to have_content "#{other_user.name}"
  end

  it "メッセージの送信先ユーザー名からユーザー詳細モーダル動作確認" do
    # メッセージデータ作成
    message = user.general_messages.create(content: "テストテキスト")
    message.receive_users << admin_user
    # ページリロード
    visit current_path
    # 送信先ユーザー名クリックからユーザー詳細モーダル表示
    expect(page).not_to have_css "#user-content"
    first(".message-user-name a").click
    expect(page).to have_css "#user-content"
    expect(find("#user-content")).to have_content "#{user.name}"
  end

  it "ホーム画面ユーザーリストサイドバー部署選択動作からユーザー詳細モーダル動作確認" do
    # サイドバーの部署選択からユーザーリスト表示
    expect(page).not_to have_css "#user-search-list"
    click_on "#{dept.name}"
    expect(page).to have_css "#user-search-list"
    expect(find("#user-search-list")).to have_content "#{dept.name}"
    # ユーザーリストのユーザー選択からユーザー詳細モーダル表示
    expect(page).not_to have_css "#user-content"
    click_on "#{user.name}"
    expect(page).to have_css "#user-content"
    expect(find("#user-content")).to have_content "#{user.name}"
  end

  it "ホーム画面ユーザーリストサイドバーグループ選択動作からユーザー詳細モーダル動作確認" do
    # コンタクトグループデータ作成
    group = admin_user.contact_groups.create(name: "テストグループ")
    group.users << user
    # ページリロード
    visit current_path
    # サイドバーコンタクトグループ選択
    expect(page).not_to have_css "#user-search-list"
    click_on "#{group.name}"
    expect(page).to have_css "#user-search-list"
    expect(find("#user-search-list")).to have_content "#{group.name}"
    expect(find("#user-search-list")).to have_content "#{user.name}"
    # ユーザーリストのユーザー選択からユーザー詳細モーダル表示
    expect(page).not_to have_css "#user-content"
    click_on "#{user.name}"
    expect(page).to have_css "#user-content"
    expect(find("#user-content")).to have_content "#{user.name}"
  end

  it "ダッシュボード動作確認" do
    # サイドメニュー展開からダッシュボードボタンクリック
    expect(page).not_to have_css "#details-content"
    find("#sidebar-btn-trigger").click
    first(".my-report-link").click
    # ダッシュボード表示確認
    sleep 1
    expect(page).to have_css "#details-content"
    expect(find("#details-content")).to have_content "#{admin_user.name}"
  end

  it "ユーザー管理動作確認" do
    # サイドメニュー展開からユーザー管理ボタンクリック
    find("#sidebar-btn-trigger").click
    expect(page).not_to have_css "#users-table-container"
    click_on "ユーザー管理"
    # ユーザー管理画面表示確認
    expect(page).to have_css "#users-table-container"
  end

  it "ユーザー管理検索動作確認" do
    # ユーザー管理画面表示
    visit users_path
    expect(all(".item").count).to eq 3
    # フォーム入力、送信
    fill_in "name", with: "#{other_user.name}"
    click_on "検索"
    sleep 1
    # 表に検索したユーザーが表示されること
    expect(all(".item").count).to eq 1
    expect(first(".item")).to have_content "#{other_user.name}"
  end
end
