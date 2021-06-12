class PaidHolidaysController < ApplicationController

  # ログインユーザー以外のアクセス拒否
  before_action :authenticate_user!

  # 勤怠情報取得
  before_action :get_sidebar_attendance, only: [:new]

  def new
    # 有給休暇新規作成
    @new_paid_holiday = PaidHoliday.new
  end

  def create
    # 有給休暇新規作成
    @new_paid_holiday = current_user.paid_holidays.build(
      paid_holiday_params
    )
    if @new_paid_holiday.save
      redirect_to user_path(current_user.public_uid)
    else
      render "new"
    end
  end

  private

  # ストロングパラメータ
  def paid_holiday_params
    params.require(:paid_holiday).permit(:holiday_on, :reason)
  end
end
