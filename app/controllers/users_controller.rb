class UsersController < ApplicationController

  # ログインユーザー以外のアクセス拒否
  before_action :authenticate_user!

  # ルートパス以外からのアクセス拒否
  before_action :root_path_limits, only: [:modal_search, :modal_show, :sidebar_search]

  # 管理ユーザー以外はリダイレクト
  before_action :current_user_admin?, only: [:index, :search]

  # 勤怠情報取得
  before_action :get_sidebar_attendance, only: [:show, :index]

  def modal_search # format :js && ajax only
    # パラメータ確認
    if params[:name].present? && params[:department].present?
      # 対象ユーザー取得
      @search_users = User.where(
        name: params[:name],
        department: params[:department],
      )
    elsif params[:name].present?
      # 対象ユーザー取得
      @search_users = User.where(name: params[:name])
    elsif params[:department].present?
      # 対象ユーザー取得
      @search_users = User.where(department: params[:department])
    end
  end

  def modal_show # format :js && ajax only
    # 対象ユーザー取得
    @other_user = User.find_by(public_uid: params[:id])
    if @other_user.present? && @other_user != current_user
      # 対象ユーザーのスケジュール取得
      @other_user_schedules = @other_user.schedules.where(work_on: Date.today).order(:start_at)
      if @other_user_schedules.present?
        # スケジュール表用配列作成
        if @other_user_schedules.last.finish_at[3] == "0"
          @other_user_work_time = (hours_time_change(@other_user_schedules.first.start_at)..hours_time_change(@other_user_schedules.last.finish_at))
        else
          @other_user_work_time = (hours_time_change(@other_user_schedules.first.start_at)..hours_time_change(@other_user_schedules.last.finish_at) + 1)
        end
        @other_user_work_length = @other_user_work_time.to_a.length
        create_other_schedule_arrays(@other_user_schedules, @other_user_work_time)
      end
      # 対象ユーザーの勤怠情報取得
      @status = @other_user.attendances.find_by(
        work_on: Date.today,
      )
      # 対象ユーザーの有給休暇情報取得
      @paid_holiday = @other_user.paid_holidays.find_by(
        holiday_on: Date.today,
      )
      # メッセージ関連
      current_messages = current_user.general_messages.includes(:general_message_relations).where(general_message_relations: { user_id: @other_user.id })
      other_messages = @other_user.general_messages.includes(:general_message_relations).where(general_message_relations: { user_id: current_user.id })
      @other_user_message_ids = current_messages.ids + other_messages.ids
      @other_user_messages = GeneralMessage.where(id: @other_user_message_ids).includes(:user).order(created_at: "DESC").page(params[:page]).per(10).reverse
      @other_user_chat_page_count = GeneralMessage.where(id: @other_user_message_ids).page(params[:page]).per(10).total_pages.to_i
      @new_message = GeneralMessage.new
      # グループ追加関連
      @new_group_relation = ContactGroupRelation.new
      groups = current_user.contact_groups.includes(:contact_group_relations)
      @group_list = []
      groups.each do |group|
        relations = group.contact_group_relations
        unless relations.find { |a| a.user_id == @other_user.id }
          @group_list.push([group.name, group.id])
        end
      end
    end
  end

  def show
    # 対象ユーザー取得
    @user = User.find_by(public_uid: params[:id])
    if @user
      if @user == current_user || current_user.admin?
        #スケジュールグラフ用カラーパレット
        @paret = ["#BD782F", "#00437C", "#6B3B41", "#B81649", "#A9B678", "#00437C", "#6B3B41", "#B81649", "#A9B678", "#00437C"]
        # 対象ユーザーのスケジュール取得
        @table_schedules = @user.schedules
        # 円グラフ用スケジュールオブジェクト生成
        circle_schedules = Array.new
        # トータル用
        @total_circle_schedule_list = total_schedule_circle(
          @user,
          @table_schedules
        )
        # 月間用
        today = Date.today
        beginning_month = today.beginning_of_month
        end_month = today.end_of_month
        month_circle_schedules = @table_schedules.select do |x|
          x.work_on >= beginning_month && x.work_on <= end_month
        end
        @month_circle_schedule_list = month_schedule_circle(
          @user,
          month_circle_schedules
        )
        # 週間用
        beginning_week = today.beginning_of_week
        end_week = today.end_of_week
        week_circle_schedules = @table_schedules.select do |x|
          x.work_on >= beginning_week && x.work_on <= end_week
        end
        @week_circle_schedule_list = week_schedule_circle(
          @user,
          week_circle_schedules
        )
        # グラフ用変数定義
        @total_work_time = 0
        @total_circle_schedule_list.each do |schedule|
          @total_work_time += schedule[1]
        end
        @month_work_time = 0
        @month_circle_schedule_list.each do |schedule|
          @month_work_time += schedule[1]
        end
        @week_work_time = 0
        @week_circle_schedule_list.each do |schedule|
          @week_work_time += schedule[1]
        end
        @total_schedule_parsents = create_schedule_parsent(
          @total_circle_schedule_list,
          @total_work_time
        )
        @month_schedule_parsents = create_schedule_parsent(
          @month_circle_schedule_list,
          @month_work_time
        )
        @week_schedule_parsents = create_schedule_parsent(
          @week_circle_schedule_list,
          @week_work_time
        )
        # 日別スケジュール用オブジェクト生成
        @schedules = @table_schedules.select { |v| v.work_on == Date.today }.sort { |a, b| a.start_at <=> b.start_at }
        if @schedules.present?
          if @schedules.last.finish_at[3] == "0"
            @work_time = (hours_time_change(
              @schedules.first.start_at
            )..hours_time_change(
              @schedules.last.finish_at
            ))
          else
            @work_time = (hours_time_change(
              @schedules.first.start_at
            )..hours_time_change(
              @schedules.last.finish_at
            ) + 1)
          end
          @work_length = @work_time.to_a.length
          create_schedule_arrays(@schedules, @work_time)
        end
        # ミーティング履歴
        @meeting_rooms = @user.meeting_rooms.where(
          "finish_at < ?", DateTime.now
        ).includes(:users).order(start_at: "DESC")
        @meeting_historys = @meeting_rooms.limit(8)
        meeting_start_week = Date.today.beginning_of_week
        meeting_end_week = Date.today.end_of_week
        @meeting_rooms_this_week = @meeting_rooms.where(
          "start_at > ? AND start_at < ?",
          meeting_start_week,
          meeting_end_week
        )
        # カレンダー用
        attendances = @user.attendances
        @stamp = attendances.map { |b| b.arrived_at.strftime("%Y%-m%-d").to_i }
        paid_holidays = @user.paid_holidays
        @paid_stamp = paid_holidays.map { |b| b.holiday_on.strftime("%Y%-m%-d").to_i }
        # 勤怠情報用
        @status = attendances.find { |x| x.work_on == Date.today }
        @paid_holiday = paid_holidays.find { |x| x.holiday_on == Date.today }
      else
        redirect_to root_path
      end
    else
      redirect_to root_path
    end
  end

  def index
    # ユーザー取得
    @users = User.all.includes(:department)
    # 検索部署セレクト用配列作成
    @department_select_option = Array.new
    department_content = Department.all
    department_content.each do |department|
      @department_select_option << [department.name, department.id]
    end
  end

  def search # format :js && ajax only
    # パラメータ確認
    if params[:name].present? && params[:department].present?
      # 対象ユーザー取得
      @users = User.where(
        name: params[:name],
        department: params[:department],
      ).includes(:department)
    elsif params[:name].present?
      # 対象ユーザー取得
      @users = User.where(
        name: params[:name],
      ).includes(:department)
    elsif params[:department].present?
      # 対象ユーザー取得
      @users = User.where(
        department: params[:department],
      ).includes(:department)
    else
      # 全てのユーザー取得
      @users = User.all.includes(:department)
    end
  end

  def sidebar_search # format :js && ajax only
    # パラメータ確認
    if params[:department_id].present?
      # 部署取得
      @department = Department.find_by(
        id: params[:department_id],
      )
    elsif params[:group_id].present?
      # グループ取得
      @group = current_user.contact_groups.find_by(
        id: params[:group_id],
      )
    end
  end
end
