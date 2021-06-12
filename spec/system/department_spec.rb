require "rails_helper"

RSpec.describe "Department", type: :system, js: true do
  let!(:not_set_dept) { create(:not_set_dept) }
  let!(:human_resources_dept) { create(:human_resources_dept) }
  let!(:sales_dept) { create(:sales_dept) }
  let!(:admin_user) { create(:admin_user, department_id: human_resources_dept.id) }

  before { login(admin_user) }

  it "部署新規登録動作確認" do
    # 部署設定画面表示
    visit new_department_path
    expect(find("#department-list")).not_to have_content "テストグループ"
    # フォーム入力
    fill_in "department_name", with: "テストグループ"
    click_button "追加"
    # 部署リストに追加されていること確認
    expect(find("#department-list")).to have_content "テストグループ"
  end

  it "部署名変更動作確認" do
    # 部署設定画面から編集画面表示
    visit new_department_path
    expect(find("#department-list")).to have_content "営業部"
    click_on "edit-#{sales_dept.id}"
    # フォーム入力
    fill_in "department_name", with: "テストグループ"
    click_button "変更"
    # 変更されているか確認
    expect(find("#department-list")).not_to have_content "営業部"
    expect(find("#department-list")).to have_content "テストグループ"
  end

  it "部署名削除動作確認" do
    # 部署設定画面表示
    visit new_department_path
    expect(find("#department-list")).to have_content "営業部"
    # 削除ボタンクリック
    click_on "destroy-#{sales_dept.id}"
    expect(page.accept_confirm).to eq "#{sales_dept.name}に設定されているユーザーは部署が未設定に設定されます。\n削除しますか？"
    # 削除した部署が表示されてないこと確認
    expect(find("#department-list")).not_to have_content "営業部"
  end
end
