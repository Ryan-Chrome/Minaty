require "rails_helper"

RSpec.describe "ContactGroup", type: :system, js: true do
  let!(:dept) { create(:human_resources_dept) }
  let!(:user) { create(:user, department_id: dept.id) }
  let!(:other_user) { create(:other_user, department_id: dept.id) }
  let!(:therd_user) { create(:therd_user, department_id: dept.id) }

  # 削除動作用
  let(:contact_group) { create(:contact_group, user_id: user.id) }
  let(:relation) { contact_group.users << [other_user, therd_user] }

  before { login(user) }

  it "グループ新規作成動作確認" do
    # 新規グループ作成フォーム表示
    find("#new-group-btn").click
    # フォーム入力しないで作成ボタンクリック
    fill_in "グループ名", with: ""
    click_on "作成"
    # メッセージ確認
    expect(find("#modal-message")).to have_content "処理に失敗しました。"
    # フォーム入力
    first(".group-container").click
    find(".user-selector-#{other_user.public_uid}").click
    fill_in "グループ名", with: "お気に入り"
    click_on "作成"
    # メッセージ確認
    expect(find("#modal-message")).to have_content "お気に入りを作成しました。"
    # 新規グループ作成のユーザー選択リストに作成したグループが追加されてるか確認
    expect(find("#new-group-user-list")).to have_content "お気に入り"
    find("#contact-group-id-#{user.contact_groups.last.id}").click
    expect(find("#new-group-user-list")).to have_content "#{other_user.name}"
    find("#new-group-close").click
    # チャット送信先設定のユーザーリストに追加されていること確認
    find("#add-send-user").click
    expect(find("#send-user-container")).to have_content "お気に入り"
    find("#send-contact-group-id-#{user.contact_groups.last.id}").click
    expect(find("#send-list")).to have_content "#{other_user.name}"
    find("#send-user-close")
    # サイドユーザーリストにグループが追加されているか
    expect(find("#group-search-list")).to have_content "お気に入り"
  end

  it "グループ削除動作確認" do
    # 削除用データ作成
    contact_group
    relation
    # ページリロード
    visit current_path
    # チャット送信先設定のユーザーリストにグループが存在すること確認
    find("#add-send-user").click
    expect(find("#send-list")).to have_css "#send-contact-group-id-#{contact_group.id}"
    find("#send-user-close").click
    # 新規グループ作成のユーザー選択リストにグループが存在すること確認
    find("#new-group-btn").click
    expect(find("#new-group-user-list")).to have_css "#contact-group-id-#{contact_group.id}"
    find("#new-group-close").click
    # サイドユーザーリストのグループ確認から展開
    expect(find("#group-search-list")).to have_css "#side-group-id-#{contact_group.id}"
    click_on "#{contact_group.name}"
    # 削除ボタンクリック
    find("#group-delete-link").click
    # 削除確認ダイアログ確認
    expect(page.accept_confirm).to eq "#{contact_group.name}を削除しますか？"
    # 削除完了ダイアログ確認
    expect(page.accept_confirm).to eq "#{contact_group.name}を削除しました。"
    # サイドユーザーリストのグループが削除されていること確認
    expect(find("#group-search-list")).not_to have_css "#side-group-id-#{contact_group.id}"
    # チャット送信先設定のユーザーリストからグループが削除されていること確認
    find("#add-send-user").click
    expect(find("#send-list")).not_to have_css "#send-contact-group-id-#{contact_group.id}"
    find("#send-user-close").click
    # 新規グループ作成のユーザー選択リストからグループが削除されていること確認
    find("#new-group-btn").click
    expect(find("#new-group-user-list")).not_to have_css "#contact-group-id-#{contact_group.id}"
  end
end
