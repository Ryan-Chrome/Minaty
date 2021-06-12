require "rails_helper"

RSpec.describe "ContactGroupRelation", type: :system, js: :true do
  let!(:dept) { create(:human_resources_dept) }
  let!(:user) { create(:user, department_id: dept.id) }
  let!(:other_user) { create(:other_user, department_id: dept.id) }
  let!(:contact_group) { create(:contact_group, user_id: user.id) }

  before { login(user) }

  it "既存のグループへのユーザー追加動作確認" do
    # ユーザー詳細表示からフォーム表示
    click_on "人事部"
    click_on "#{other_user.name}"
    expect(find("#Modal")).not_to have_css "#add-user-to-group"
    click_on "グループ追加"
    expect(find("#Modal")).to have_css "#add-user-to-group"
    # フォーム入力
    select "#{contact_group.name}", from: "contact_group_relation_contact_group_id"
    click_on "group-relation-submit"
    # メッセージ確認
    expect(find("#modal-message")).to have_content "#{contact_group.name}に追加しました。"
    # 追加できるグループがないことを表示しているか確認
    expect(find("#add-user-to-group")).to have_css "#add-group-list-non-text"
    # # モーダルを閉じる
    find("#add-user-to-group-close").click
    expect(page).not_to have_css "#add-user-to-group"
    # サイドユーザーリストでグループに追加されているか確認
    find("#user-search-section-back-btn").click
    click_on "#{contact_group.name}"
    expect(find("#user-search-list")).to have_content "#{other_user.name}"
    find("#user-search-section-back-btn").click
    # グループ新規作成モーダルのユーザー選択リストでグループにユーザーが追加されてるか確認
    find("#new-group-btn").click
    find("#contact-group-id-#{contact_group.id}").click
    expect(find("#contact-group-id-#{contact_group.id}")).to have_content "#{other_user.name}"
    find("#new-group-close").click
    # チャット送信先設定のユーザー選択リストでグループにユーザーが追加されているか確認
    find("#add-send-user").click
    find("#send-contact-group-id-#{contact_group.id}").click
    expect(find("#send-contact-group-id-#{contact_group.id}")).to have_content "#{other_user.name}"
  end
end
