class PaidHolidaysController < ApplicationController

    # ログインユーザー以外のアクセス拒否
    before_action :authenticate_user!

    def new
        @new_paid_holiday = PaidHoliday.new
    end

    def create
        @new_paid_holiday = current_user.paid_holidays.build(
            paid_holiday_params
        )
        if @new_paid_holiday.save
            redirect_to management_path(current_user.public_uid)
        else
            render "new"
        end
    end

    private

        def paid_holiday_params
            params.require(:paid_holiday).permit(:holiday_on, :reason)
        end

end
