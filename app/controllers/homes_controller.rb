class HomesController < ApplicationController

  # 勤怠情報取得
  before_action :get_sidebar_attendance

  def home
    if user_signed_in?
      # タイマーON
      @timer_on = "on"
      # お知らせOFF
      @notice_message = "off"
      # 部署選択用
      @departments = Department.where.not(name: "未設定").includes(:users)
      @department_select_option = Array.new
      @departments.each do |department|
        @department_select_option << [department.name, department.id]
      end
      # コンタクトグループ取得
      @contact_groups = current_user.contact_groups.includes(:users)
      # コンタクトグループ作成
      @new_group = ContactGroup.new
      # メッセージ作成
      @new_message = GeneralMessage.new
      # メッセージ取得
      message_ids = 
        current_user.general_message_ids + current_user.receive_message_ids
      @messages = GeneralMessage.where(
        id: message_ids
      ).includes(
        :user, :receive_users
      ).order(created_at: "DESC").page(params[:page]).per(10).reverse
      @page_count = GeneralMessage.where(
        id: message_ids
      ).page(params[:page]).per(10).total_pages.to_i
      # スケジュール取得
      @schedules = current_user.schedules.where(
        work_on: Date.today
      ).order(:start_at)
      if @schedules.present?
        if @schedules.last.finish_at[3] == "0"
          @work_time = (
            hours_time_change(
              @schedules.first.start_at
            )..hours_time_change(
              @schedules.last.finish_at
            )
          )
        else
          @work_time = (
            hours_time_change(
              @schedules.first.start_at
            )..hours_time_change(
              @schedules.last.finish_at
            ) + 1
          )
        end
        @work_length = @work_time.to_a.length
        create_schedule_arrays(@schedules, @work_time)
      end
    end
  end
end
