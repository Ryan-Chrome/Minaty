module AttendanceModule

    def arrive_work_stamping
        find("#sidebar-btn-trigger").click
        page.accept_confirm do
            click_on "出勤"
        end
    end

    def leave_work_stamping
        find("#sidebar-btn-trigger").click
        page.accept_confirm do
            click_on "退勤"
        end
    end

    def all_work_stamping
        find("#sidebar-btn-trigger").click
        page.accept_confirm do
            click_on "出勤"
        end
        page.accept_confirm do
            click_on "退勤"
        end
    end

    def paid_holiday_application
        visit new_paid_holiday_path
        
        fill_in "paid_holiday_reason", with: "私用"
        click_button "申請"
    end

end