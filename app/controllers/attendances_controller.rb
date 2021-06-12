class AttendancesController < ApplicationController
  require "csv"

  # ログインユーザー以外のアクセス拒否
  before_action :authenticate_user!

  # 管理ユーザー以外はホームへリダイレクト
  before_action :current_user_admin?, only: [:index, :search, :csv_download]

  # 勤怠情報取得
  before_action :get_sidebar_attendance, only: [:index]

  def create # format :js & ajax only
    @sidebar_attendance = current_user.attendances.create(
      work_on: Date.today,
      arrived_at: DateTime.now,
    )
  end

  def update # format :js & ajax only
    @sidebar_attendance = current_user.attendances.find_by(
      id: params[:id],
      work_on: Date.today,
    )
    if @sidebar_attendance.present?
      unless @sidebar_attendance.left_at.present?
        @sidebar_attendance.update(left_at: DateTime.now)
      end
    end
  end

  def index
    date = Date.today
    # 勤怠データが存在するユーザーを取得
    @attendance_users = User.includes(
      :attendances, :department
    ).where(attendances: { work_on: date })
    # 有給休暇を取得しているユーザーを取得
    @holiday_users = User.includes(
      :paid_holidays, :department
    ).where(paid_holidays: { holiday_on: date })
    # 上記2つに当てはまらないユーザーを取得
    @no_status_users = User.where.not(
      id: @attendance_users.ids.concat(@holiday_users.ids)
    ).includes(:department)
    # 検索フォーム部署セレクト用
    @department_select_option = Array.new
    department_content = Department.all
    department_content.each do |department|
      @department_select_option << [department.name, department.id]
    end
  end

  def search #format :js & ajax only
    # 日付定義
    if params[:date].present?
      date = Date.parse(params[:date])
    else
      date = Date.today
    end
    # ユーザー取得
    if params[:name].present? && params[:department].present?
      search_users = User.where(
        name: params[:name], department: params[:department]
      )
    elsif params[:name].present?
      search_users = User.where(name: params[:name])
    elsif params[:department].present?
      search_users = User.where(department: params[:department])
    else
      search_users = User.all
    end
    # 定義した日付で取得したユーザーから勤怠データが存在するユーザーを取得
    @attendance_users = search_users.includes(
      :attendances, :department
    ).where(attendances: { work_on: date })
    # 定義した日付で取得したユーザーから有給休暇ユーザーを取得
    @holiday_users = search_users.includes(
      :paid_holidays, :department
    ).where(paid_holidays: { holiday_on: date })
    # 取得したユーザーから上記2つの当てはまらないユーザーを取得
    @no_status_users = search_users.where.not(
      id: @attendance_users.ids.concat(@holiday_users.ids)
    ).includes(:department)
  end

  def csv_download #format :csv
    # 日付取得
    start = Date.parse(params[:start_date]) if params[:start_date].present?
    finish = Date.parse(params[:finish_date]) if params[:finish_date].present?
    if start && finish && start <= finish
      date = (start..finish)
      # 対象ユーザー取得
      if params[:holiday] == "1"
        if params[:name].present? && params[:department].present?
          users = User.where(
            name: params[:name],
            department_id: params[:department]
          ).includes(:department, :attendances, :paid_holidays)
        elsif params[:name].present?
          users = User.where(
            name: params[:name]
          ).includes(:department, :attendances, :paid_holidays)
        elsif params[:department].present?
          users = User.where(
            department_id: params[:department]
          ).includes(:department, :attendances, :paid_holidays)
        else
          users = User.includes(:department, :attendances, :paid_holidays)
        end
      else
        if params[:name].present? && params[:department].present?
          users = User.where(
            name: params[:name],
            department_id: params[:department]
          ).includes(:department, :attendances)
        elsif params[:name].present?
          users = User.where(
            name: params[:name]
          ).includes(:department, :attendances)
        elsif params[:department].present?
          users = User.where(
            department_id: params[:department]
          ).includes(:department, :attendances)
        else
          users = User.includes(:department, :attendances)
        end
      end
      # 対象ユーザー並び替え
      if params[:sort] == "kana"
        users = users.sort{ |a, b| a.kana <=> b.kana }
      else
        users = users.sort{ |a, b| a.department.name <=> b.department.name }
      end
      if params[:holiday] == "1"
        attendance_csv(users, date, true)
      else
        attendance_csv(users, date, false)
      end
    end
  end

  private

  def attendance_csv(users, period, holiday_on)
    csv_data = CSV.generate do |csv|
      column_names = ["ユーザー名（#{users.count}名）"]
      period.to_a.map {|a| column_names << a.strftime("%Y/%m/%d")}
      column_names << "統計"
      csv << column_names
      users.each do |user|
        arrived_values = ["#{user.name}（#{user.department.name}）"]
        left_values = ["-"]
        total_values = ["勤務時間"]
        avg_arrived_values = []
        avg_left_values = []
        avg_total_values = []
        attendances = user.attendances
        period.each do |day|
          if attendance = attendances.find { |a| a.work_on == day }
            arrived_at = attendance.arrived_at
            left_at = attendance.left_at
            if arrived_at.present?
              arrived_values << arrived_at.strftime("%H時%M分")
              total_date = arrived_at.strftime("%H:%M:%S").split(/:/)
              avg_arrived_values <<
                total_date.map(&:to_i).inject { |x, y| x * 60 + y }
            else
              arrived_values << "-"
            end
            if left_at.present?
              left_values << left_at.strftime("%H時%M分")
              total_date = left_at.strftime("%H:%M:%S").split(/:/)
              avg_left_values <<
                total_date.map(&:to_i).inject { |x, y| x * 60 + y }
            else
              left_values << "-"
            end
            if arrived_at.present? && left_at.present?
              time = left_at - arrived_at
              total_values << Time.at(time).utc.strftime("%-H時間%-M分")
              avg_total_values << time
            else
              total_values << "-"
            end
          else
            if holiday_on
              paid_holidays = user.paid_holidays
              if paid_holidays.find {|a| a.holiday_on == day}
                arrived_values << "有"
                left_values << "有"
                total_values << "有"
              else
                arrived_values << "-"
                left_values << "-"
                total_values << "-"
              end
            else
              arrived_values << "-"
              left_values << "-"
              total_values << "-"
            end
          end
        end

        arrived_values << "平均"
        left_values << "-"
        total_values << "合計"

        if avg_arrived_values.present? && avg_left_values.present?
          total_begin = avg_arrived_values.inject(:+) / avg_arrived_values.length
          total_finish = avg_left_values.inject(:+) / avg_left_values.length
          arrived_values << Time.at(total_begin).utc.strftime("%H時%M分")
          left_values << Time.at(total_finish).utc.strftime("%H時%M分")
        end

        if avg_total_values.present?
          total_time = avg_total_values.inject(:+)
          if total_time >= 3600
            hour = (total_time / 3600).floor
            rem = total_time % 3600
            minute = (rem / 60).floor
            total_values << "#{hour}時間#{minute}分"
          elsif total_time >= 60
            minute = (total_time / 60).floor
            total_values << "#{minute}分"
          else
            total_values << "-"
          end
        end

        csv << arrived_values
        csv << left_values
        csv << total_values
      end
    end
    send_data(csv_data, filename: "勤怠(任意).csv")
  end
end
