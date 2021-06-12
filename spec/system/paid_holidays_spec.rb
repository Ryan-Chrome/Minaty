require "rails_helper"

RSpec.describe "PaidHoliday", type: :system, js: true do
  let!(:dept) { create(:human_resources_dept) }
  let!(:user) { create(:user, department_id: dept.id) }

  before { login(user) }

  it "有給休暇申請動作確認" do
    # 有給休暇申請画面表示
    visit new_paid_holiday_path
    # フォーム空入力、送信
    click_button "申請"
    # 'field_with_errors'の存在確認
    expect(find("#paid-holiday-form")).to have_css ".field_with_errors"
    # フォーム入力
    fill_in "paid_holiday_holiday_on", with: Date.today
    fill_in "paid_holiday_reason", with: "私用"
    click_button "申請"
    # ダッシュボード画面表示
    expect(find("#user-details")).to have_content "ダッシュボード"
  end
end
