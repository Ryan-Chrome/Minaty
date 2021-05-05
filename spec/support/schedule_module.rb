module ScheduleModule

    def schedule_create
        click_on "add-schedule-btn"
        click_button "次へ"

        fill_in "内容", with: "テスト会議"
        select "10", from: "schedule_start_at_4i"
        select "00", from: "schedule_start_at_5i"
        select "15", from: "schedule_finish_at_4i"
        select "30", from: "schedule_finish_at_5i"
        click_button "登録"

        find("#add-schedule-next-close").click
    end

end