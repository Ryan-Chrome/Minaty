require 'rails_helper'

RSpec.describe "Attendance", type: :system, js: true do

    let!(:admin_user){ create(:admin_user) }

    # 打刻動作確認
    describe "operation check" do

        # 出・退勤
        it "Stamping" do
            login(admin_user)

            # 出勤打刻動作
            find("#sidebar-btn-trigger").click
            expect(find("#attendance-content")).not_to have_css ".leave"
            click_on "出勤"
            expect(page.accept_confirm).to eq "出勤時刻を打刻します"
            expect(find("#attendance-content")).to have_content "出勤時間"
            expect(find("#attendance-content")).to have_css ".leave"

            # 退勤打刻動作
            click_on "退勤"
            expect(page.accept_confirm).to eq "退勤時刻を打刻します"
            expect(find("#attendance-content")).to have_content "退勤時間"
        end

        # 有給申請
        context "Paid_application" do
            it "Success" do
                login(admin_user)

                find("#sidebar-btn-trigger").click
                click_on "有給休暇申請"
    
                expect(find("#paid-holiday-form")).to have_content "有給休暇申請"
                fill_in "paid_holiday_holiday_on", with: Date.today
                fill_in "paid_holiday_reason", with: "私用"
                click_button "申請"
    
                expect(find("#user-container")).to have_content "ダッシュボード"
                find("#sidebar-btn-trigger").click
    
                expect(first("#attendance-content .holiday")).to have_content "有給休暇中"
            end

            it "Error" do
                login(admin_user)

                find("#sidebar-btn-trigger").click
                click_on "有給休暇申請"

                fill_in "paid_holiday_holiday_on", with: Date.today
                click_button "申請"

                expect(first(".field_with_errors label")).to have_content "取得理由"

                fill_in "paid_holiday_holiday_on", with: ""
                fill_in "paid_holiday_reason", with: "私用"
                click_button "申請"

                expect(first(".field_with_errors label")).to have_content "取得日"

                fill_in "paid_holiday_holiday_on", with: Date.today
                fill_in "paid_holiday_reason", with: "私用"
                click_button "申請"

                visit new_paid_holiday_path
                fill_in "paid_holiday_holiday_on", with: Date.today
                fill_in "paid_holiday_reason", with: "私用"
                click_button "申請"

                expect(first(".field_with_errors label")).to have_content "取得日"
            end
        end
    end

    # 管理者ページ　勤怠管理動作確認
    describe "management page" do
        # 勤怠情報　反映確認
        it "Reflected" do
            login(admin_user)
            visit managements_attendance_path
            
            expect(find("#myTable").all(".attendance")[0][:class]).to include "before-work"

            arrive_work_stamping
            visit current_path

            expect(find("#myTable").all(".attendance")[0][:class]).to include "attend-work"

            leave_work_stamping
            visit current_path

            expect(find("#myTable").all(".attendance")[0][:class]).to include "after-leave"
        end

        # 有給申請反映確認
        it "Paid holiday reflected" do
            login(admin_user)
            paid_holiday_application

            visit managements_attendance_path
            expect(find("#myTable").all(".attendance")[0][:class]).to include "paid-status"
        end

        # 検索動作
        context "Search" do
            let!(:sales_user){ create(:sales_user) }
            it "operation" do
                login(admin_user)
                visit managements_attendance_path

                expect(find("#myTable")).to have_content "admin_user"
                expect(find("#myTable")).to have_content "sales_user"

                fill_in "name", with: "#{admin_user.name}"
                click_button "検索"

                expect(find("#myTable")).to have_content "admin_user"
                expect(find("#myTable")).not_to have_content "sales_user"

                fill_in "name", with: ""
                select "営業部", from: "department"
                click_button "検索"

                expect(find("#myTable")).not_to have_content "admin_user"
                expect(find("#myTable")).to have_content "sales_user"
            end
        end
    end

end