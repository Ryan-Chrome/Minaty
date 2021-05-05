class ManagementsController < ApplicationController

    require 'csv'

    # ログインユーザー以外のアクセス拒否
    before_action :authenticate_user!

    # 管理ユーザー以外はリダイレクト
    before_action :current_user_admin?, only:[:index, :attendance, :attendance_search, :import_attendance]

    def index
        # user management
        if params[:name].present? && params[:department].present?
            @users = User.where(
                name: params[:name],
                department: params[:department]
            )
        elsif params[:name].present?
            @users = User.where(
                name: params[:name]
            )
        elsif params[:department].present?
            @users = User.where(
                department: params[:department]
            )
        else
            @users = User.all
        end

        @department_select_option = Array.new
        department_content = User.select(:department).distinct
        department_content.each do |department|
            @department_select_option << department.department
        end
    end

    def show
        # 対象ユーザー取得
        @user = User.find_by(public_uid: params[:id])
        if @user == current_user || current_user.admin?
            #スケジュールグラフ用カラーパレット
            @paret = ["#BD782F", "#00437C", "#6B3B41", "#B81649", "#A9B678"]
            # 対象ユーザーのスケジュール取得
            @schedules = @user.schedules
            # 円グラフ用スケジュールオブジェクト生成
            circle_schedules = Array.new
            # トータル用
            total_circle_schedules = @schedules.select(:name).distinct
            @total_circle_schedule_list = total_schedule_circle(
                @user,
                total_circle_schedules
            )
            # 月間用
            today = Date.today
            beginning_month = today.beginning_of_month
            end_month = today.end_of_month
            month_circle_schedules = @schedules.where(
                "work_on >= ? AND work_on <= ?",
                beginning_month,
                end_month
            ).select(:name).distinct
            @month_circle_schedule_list = month_schedule_circle(
                @user, 
                month_circle_schedules,
                beginning_month,
                end_month
            )
            # 週間用
            beginning_week = today.beginning_of_week
            end_week = today.end_of_week
            week_circle_schedules = @schedules.where(
                "work_on >= ? AND work_on <= ?",
                beginning_week,
                end_week
            ).select(:name).distinct
            @week_circle_schedule_list = week_schedule_circle(
                @user,
                week_circle_schedules,
                beginning_week,
                end_week
            )

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
            @schedules = @user.schedules.where(work_on: Date.today).order(:start_at)
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

            # ミーティング履歴
            @meeting_rooms = @user.meeting_rooms.where(
                "finish_at < ?", DateTime.now
            ).order(start_at: "DESC")

            @meeting_historys = @meeting_rooms.limit(8)

            meeting_start_week = Date.today.beginning_of_week
            meeting_end_week = Date.today.end_of_week
            @meeting_rooms_this_week = @meeting_rooms.where(
                "start_at > ? AND start_at < ?",
                meeting_start_week,
                meeting_end_week
            )

            attendances = @user.attendances
            @stamp = attendances.map { |b| b.arrived_at.strftime('%Y%-m%-d').to_i }
            paid_holidays = @user.paid_holidays
            @paid_stamp = paid_holidays.map{ |b| b.holiday_on.strftime('%Y%-m%-d').to_i }

            @status = @user.attendances.find_by(
                work_on: Date.today
            )

            @paid_holiday = @user.paid_holidays.find_by(
                holiday_on: Date.today
            )
        else
            redirect_to root_path
        end
    end

    def attendance
        @attendances = Attendance.where(
            work_on: Date.today
        ).order(:left_at)
        attendance_users = @attendances.map {|a| a.user.public_uid }
        # データがないユーザー
        @not_users = User.where.not(public_uid: attendance_users)

        # 有給休暇取得
        paids = PaidHoliday.where(holiday_on: Date.today)
        @paid_users = paids.map {|a| a.user.public_uid }
    end

    def attendance_search
        if params[:date].present?
            date = Date.parse(params[:date])
        else
            date = Date.today
        end
        if params[:name].present? && params[:department].present?
            search_users = User.where(name: params[:name], department: params[:department])
        elsif params[:name].present?
            search_users = User.where(name: params[:name])
        elsif params[:department].present?
            search_users = User.where(department: params[:department])
        end
        if params[:name].present? || params[:department].present?
            all_attendances = Attendance.where(
                work_on: date
            ).order(:left_at)
            @attendances = all_attendances.where(user_id: search_users.ids)
        else
            @attendances = Attendance.where(
                work_on: date
            ).order(:left_at)
        end
        attendance_users = @attendances.map { |a| a.user.public_uid }
        if search_users.present?
            @not_users = search_users.where.not(public_uid: attendance_users)
        else
            @not_users = User.where.not(public_uid: attendance_users)
        end
        # 有給休暇取得
        paids = PaidHoliday.where(holiday_on: Date.today)
        @paid_users = paids.map {|a| a.user.public_uid }
        respond_to do |format|
            format.js
        end
    end

    def import_attendance
        if params[:period] == "day"
            name = "#{DateTime.now.strftime("%Y/%m/%d")}"
            respond_to do |format|
                format.csv do |csv|
                    attendance_day_csv(name)
                end
            end
        elsif params[:period] == "week"
            start = DateTime.now.beginning_of_week.strftime("%Y/%m/%d")
            finish = DateTime.now.end_of_week.strftime("%Y/%m/%d")
            name = "#{start}~#{finish}"
            respond_to do |format|
                format.csv do |csv|
                    attendance_week_csv(name)
                end
            end
        elsif params[:period] == "month"
            name = DateTime.now.strftime("%Y年%m月")
            respond_to do |format|
                format.csv do |csv|
                    attendance_month_csv(name)
                end
            end
        elsif params[:start_time].present? && params[:finish_time].present?
            start = Date.parse(params[:start_time])
            finish = Date.parse(params[:finish_time])
            respond_to do |format|
                format.csv do |csv|
                    attendance_any_csv(start, finish)
                end
            end
        end
    end

    private
    def attendance_day_csv(date)
        csv_data = CSV.generate do |csv|
            @users = User.all
            column_names = ["ユーザー名（#{@users.count}名）", "#{date}"]
            csv << column_names
            @users.each do |user|
                arrived_values = ["#{user.name}（#{user.department}）"]
                left_values = ["-"]
                total_values = ["勤務時間"]
                attendance = user.attendances.find_by(
                    work_on: Date.today
                )
                if attendance.present?
                    arrived_at = attendance.arrived_at
                    left_at = attendance.left_at
                    if arrived_at.present?
                        arrived_values << arrived_at.strftime("%H時%M分")
                    else
                        arrived_values << "-"
                    end
                    if left_at.present?
                        left_values << left_at.strftime("%H時%M分")
                    else
                        left_values << "-"
                    end
                    if arrived_at.present? && left_at.present?
                        time = left_at - arrived_at
                        total_values << Time.at(time).utc.strftime("%-H時間%-M分")
                    else
                        total_values << "-"
                    end
                else
                    arrived_values << "-"
                    left_values << "-"
                    total_values << "-"
                end
                csv << arrived_values
                csv << left_values
                csv << total_values
            end
        end
        send_data(csv_data, filename: "勤怠(#{date}).csv")
    end

    def attendance_week_csv(name)
        csv_data = CSV.generate do |csv|
            @users = User.all
            column_names = ["ユーザー名（#{@users.count}名）"]
            start = Date.today.beginning_of_week
            finish = Date.today.end_of_week
            arr = (start..finish).to_a
            arr.map {|n| column_names << n.strftime("%Y/%m/%d") }
            column_names << "統計"
            csv << column_names
            @users.each do |user|
                arrived_values = ["#{user.name}（#{user.department}）"]
                left_values = ["-"]
                total_values = ["勤務時間"]
                avg_arrived_values = []
                avg_left_values = []
                avg_total_values = []
                arr.each do |obj|
                    attendance = user.attendances.find_by(
                        work_on: obj
                    )
                    if attendance.present?
                        arrived_at = attendance.arrived_at
                        left_at = attendance.left_at
                        if arrived_at.present?
                            arrived_values << arrived_at.strftime("%H時%M分")
                            total_date = arrived_at.strftime("%H:%M:%S").split(/:/)
                            avg_arrived_values <<
                                total_date.map(&:to_i).inject{|x,y| x*60+y}
                        else
                            arrived_values << "-"
                        end
                        if left_at.present?
                            left_values << left_at.strftime("%H時%M分")
                            total_date = left_at.strftime("%H:%M:%S").split(/:/)
                            avg_left_values <<
                                total_date.map(&:to_i).inject{|x,y| x*60+y}
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
                        arrived_values << "-"
                        left_values << "-"
                        total_values << "-"
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
        send_data(csv_data, filename: "勤怠(#{name}).csv")
    end

    def attendance_month_csv(name)
        csv_data = CSV.generate do |csv|
            @users = User.all
            column_names = ["ユーザー名（#{@users.count}名）"]
            start = Date.today.beginning_of_month
            finish = Date.today.end_of_month
            arr = (start..finish).to_a
            arr.map {|n| column_names << n.strftime("%Y/%m/%d") }
            column_names << "統計"
            csv << column_names
            @users.each do |user|
                arrived_values = ["#{user.name}（#{user.department}）"]
                left_values = ["-"]
                total_values = ["勤務時間"]
                avg_arrived_values = []
                avg_left_values = []
                avg_total_values = []
                arr.each do |obj|
                    attendance = user.attendances.find_by(
                        work_on: obj
                    )
                    if attendance.present?
                        arrived_at = attendance.arrived_at
                        left_at = attendance.left_at
                        if arrived_at.present?
                            arrived_values << arrived_at.strftime("%H時%M分")
                            total_date = arrived_at.strftime("%H:%M:%S").split(/:/)
                            avg_arrived_values << 
                                total_date.map(&:to_i).inject{|x,y| x*60+y}
                        else
                            arrived_values << "-"
                        end
                        if left_at.present?
                            left_values << left_at.strftime("%H時%M分")
                            total_date = left_at.strftime("%H:%M:%S").split(/:/)
                            avg_left_values << 
                                total_date.map(&:to_i).inject{|x,y| x*60+y}
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
                        arrived_values << "-"
                        left_values << "-"
                        total_values << "-"
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
        send_data(csv_data, filename: "勤怠(#{name}).csv")
    end

    def attendance_any_csv(s, f)
        csv_data = CSV.generate do |csv|
            @users = User.all
            column_names = ["ユーザー名（#{@users.count}名）"]
            arr = (s..f).to_a
            arr.map {|n| column_names << n.strftime("%Y/%m/%d") }
            column_names << "統計"
            csv << column_names
            @users.each do |user|
                arrived_values = ["#{user.name}（#{user.department}）"]
                left_values = ["-"]
                total_values = ["勤務時間"]
                avg_arrived_values = []
                avg_left_values = []
                avg_total_values = []
                arr.each do |obj|
                    attendance = user.attendances.find_by(
                        work_on: obj
                    )
                    if attendance.present?
                        arrived_at = attendance.arrived_at
                        left_at = attendance.left_at
                        if arrived_at.present?
                            arrived_values << arrived_at.strftime("%H時%M分")
                            total_date = arrived_at.strftime("%H:%M:%S").split(/:/)
                            avg_arrived_values <<
                                total_date.map(&:to_i).inject{|x,y| x*60+y}
                        else
                            arrived_values << "-"
                        end
                        if left_at.present?
                            left_values << left_at.strftime("%H時%M分")
                            total_date = left_at.strftime("%H:%M:%S").split(/:/)
                            avg_left_values <<
                                total_date.map(&:to_i).inject{|x,y| x*60+y}
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
                        arrived_values << "-"
                        left_values << "-"
                        total_values << "-"
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
