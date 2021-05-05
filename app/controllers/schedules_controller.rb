class SchedulesController < ApplicationController
    # schedulesに関するrouteは全てJSフォーマット以外受け付けない
    #　(routesファイル参照)

    # ログインユーザー以外のアクセス拒否
    before_action :authenticate_user!

    # ルートパス以外からのアクセス拒否
    before_action :root_path_limits, only:[:new, :meeting_new, :edit, :update, :destroy]

    # ルートパス＆自分の持つミーティングルーム以外からのアクセス拒否
    before_action :validation_timer_path, only:[:add_timer, :create]

    # スケジュール追加日付送信後新規作成フォーム表示
    def new
        @schedule = current_user.schedules.build
        @new_schedule_date = "#{params[:add_date].to_date}"
        @schedules = current_user.schedules.where(work_on: @new_schedule_date).order(:start_at)
        if @schedules.present?
            if @schedules.last.finish_at[3] == "0"
                @work_time = (hours_time_change(@schedules.first.start_at)..hours_time_change(@schedules.last.finish_at))
            else
                @work_time = (hours_time_change(@schedules.first.start_at)..hours_time_change(@schedules.last.finish_at) + 1)
            end
            @work_length = @work_time.to_a.length
            create_schedule_arrays(@schedules, @work_time)
        end
        respond_to do |format|
            format.js
        end
    end

    # ミーティング通知から新規登録フォーム表示
    def meeting_new
        @meeting_room = current_user.meeting_rooms.find_by(public_uid: params[:meeting_room_id])
        @schedule = current_user.schedules.build
        @new_schedule_date = "#{@meeting_room.start_at.strftime("%Y-%m-%d")}"
        @schedules = current_user.schedules.where(work_on: @new_schedule_date).order(:start_at)
        if @schedules.present?
            if @schedules.last.finish_at[3] == "0"
                @work_time = (hours_time_change(@schedules.first.start_at)..hours_time_change(@schedules.last.finish_at))
            else
                @work_time = (hours_time_change(@schedules.first.start_at)..hours_time_change(@schedules.last.finish_at) + 1)
            end
            @work_length = @work_time.to_a.length
            create_schedule_arrays(@schedules, @work_time)
        end
        respond_to do |format|
            format.js 
        end
    end

    # タイマーから新規登録フォーム表示
    def add_timer
        @start_hours = params[:start_time][0..1]
        @start_minutes = "#{params[:start_time][3..4].to_i.round(-1)}"
        @end_hours = params[:end_time][0..1]
        @end_minutes = "#{params[:end_time][3..4].to_i.round(-1)}"
        if @start_minutes == "0" && @start_minutes == "60"
            @start_minutes = "00"
            if @start_minutes == "60"
                @start_hours = "#{@start_hours.to_i + 1}"
            end
        end
        if @start_hours == "24"
            @start_hours = "23"
            @start_minutes = "50"
        end
        if @end_minutes == "0" && @end_minutes == "60"
            @end_minutes = "00"
            if @end_minutes == "60"
                @end_hours = "#{@end_hours.to_i + 1}"
            end
        end
        if schedule_hours_params_check(@start_hours) && schedule_minutes_params_check(@start_minutes) && schedule_hours_params_check(@end_hours) && schedule_minutes_params_check(@end_minutes)
            add_start_time = @start_hours + @start_minutes
            add_end_time = @end_hours + @end_minutes
            if add_start_time > add_end_time
                @end_hours = "24"
                @end_minutes = "00"
            end
            @new_schedule_date = Date.today
            @schedule = current_user.schedules.build
            @schedules = current_user.schedules.where(work_on: @new_schedule_date).order(:start_at)
            if @schedules.present?
                if @schedules.last.finish_at[3] == "0"
                    @work_time = (hours_time_change(@schedules.first.start_at)..hours_time_change(@schedules.last.finish_at))
                else
                    @work_time = (hours_time_change(@schedules.first.start_at)..hours_time_change(@schedules.last.finish_at) + 1)
                end
                @work_length = @work_time.to_a.length
                create_schedule_arrays(@schedules, @work_time)
            end
        end
        respond_to do |format|
            if root_url == request.referer
                format.js
            else
                format.js { render "schedules/add_timer_for_meeting" }
            end
        end
    end

    # スケジュール新規作成
    def create
        add_start_time = params[:schedule]["start_at(4i)"] + ":" + params[:schedule]["start_at(5i)"]
        add_end_time = params[:schedule]["finish_at(4i)"] + ":" + params[:schedule]["finish_at(5i)"]
        start_time = add_start_time.delete("^0-9").to_i
        end_time = add_end_time.delete("^0-9").to_i
        registered_schedule = current_user.schedules.where(work_on: params[:schedule][:work_on]).order(:start_at)
        registered_time = []
        registered_schedule.each do |schedule|
            registered_start_time = (schedule.start_at.delete("^0-9").to_i)+1
            registered_end_time = (schedule.finish_at.delete("^0-9").to_i)-1
            registered_time.concat((registered_start_time..registered_end_time).to_a)
        end
        unless registered_time.any?(start_time..end_time)
            @schedule = current_user.schedules.build(
                work_on: params[:schedule][:work_on],
                name: params[:schedule][:name],
                start_at: add_start_time,
                finish_at: add_end_time
            )
            if @schedule.save
                @new_schedule_date = @schedule.work_on
                @schedules = current_user.schedules.where(work_on: @schedule.work_on).order(:start_at)
                if @schedules.last.finish_at[3] == "0"
                    @work_time = (hours_time_change(@schedules.first.start_at)..hours_time_change(@schedules.last.finish_at))
                else
                    @work_time = (hours_time_change(@schedules.first.start_at)..hours_time_change(@schedules.last.finish_at) + 1)
                end
                @work_length = @work_time.to_a.length
                create_schedule_arrays(@schedules, @work_time)
                @schedule = current_user.schedules.build
            end
        end
        respond_to do |format|
            if root_url == request.referer
                format.js
            else
                format.js { render "schedules/create_for_meeting" }
            end
        end
    end

    # スケジュール編集項目選択後フォーム
    def edit
        @schedule = current_user.schedules.find_by(id: params[:id])
        if @schedule.present?
            @schedules = current_user.schedules.where(work_on: @schedule.work_on).order(:start_at)
            if @schedules.last.finish_at[3] == "0"
                @work_time = (hours_time_change(@schedules.first.start_at)..hours_time_change(@schedules.last.finish_at))
            else
                @work_time = (hours_time_change(@schedules.first.start_at)..hours_time_change(@schedules.last.finish_at) + 1)
            end
            @work_length = @work_time.to_a.length
            create_schedule_arrays(@schedules, @work_time)
        end
        respond_to do |format|
            format.js
        end
    end

    # スケジュール編集
    def update
        @schedule = current_user.schedules.find_by(id: params[:id])
        if @schedule.present?
            edit_start_time = params[:schedule]["edit_start_at(4i)"] + ":" + params[:schedule]["edit_start_at(5i)"]
            edit_end_time = params[:schedule]["edit_finish_at(4i)"] + ":" + params[:schedule]["edit_finish_at(5i)"]
            start_time = edit_start_time.delete("^0-9").to_i
            end_time = edit_end_time.delete("^0-9").to_i
            registered_schedules = current_user.schedules.where(work_on: @schedule.work_on).order(:start_at)
            registered_time = []
            registered_schedules.each do |schedule|
                if schedule != @schedule
                    registered_start_time = (schedule.start_at.delete("^0-9").to_i)+1
                    registered_end_time = (schedule.finish_at.delete("^0-9").to_i)-1
                    registered_time.concat((registered_start_time..registered_end_time).to_a)
                end
            end
            unless registered_time.any?(start_time..end_time)
                if @schedule.update(name: params[:schedule][:name], start_at: edit_start_time, finish_at: edit_end_time)
                    @schedules = current_user.schedules.where(work_on: @schedule.work_on).order(:start_at)
                    if @schedules.last.finish_at[3] == "0"
                        @work_time = (hours_time_change(@schedules.first.start_at)..hours_time_change(@schedules.last.finish_at))
                    else
                        @work_time = (hours_time_change(@schedules.first.start_at)..hours_time_change(@schedules.last.finish_at) + 1)
                    end
                    @work_length = @work_time.to_a.length
                    create_schedule_arrays(@schedules, @work_time)
                end
            end
        end
        respond_to do |format|
            format.js
        end
    end

    # スケジュール削除
    def destroy
        @destroy_schedule = current_user.schedules.find_by(id: params[:id])
        if @destroy_schedule.present?
            @destroy_schedule.destroy
            @schedules = current_user.schedules.where(work_on: @destroy_schedule.work_on).order(:start_at)
            if @schedules.present?
                if @schedules.last.finish_at[3] == "0"
                    @work_time = (hours_time_change(@schedules.first.start_at)..hours_time_change(@schedules.last.finish_at))
                else
                    @work_time = (hours_time_change(@schedules.first.start_at)..hours_time_change(@schedules.last.finish_at) + 1)
                end
                @work_length = @work_time.to_a.length
                create_schedule_arrays(@schedules, @work_time)
            end
        end
        respond_to do |format|
            format.js
        end
    end

    # current_user スケジュール日付変更
    def date_change
        if params[:schedule_date].present?
            #ホーム、スケジュール日付変更
            @schedules = current_user.schedules.where(
                work_on: params[:schedule_date]
            ).order(:start_at)
        elsif params[:edit_schedule_date].present?
            #スケジュール編集画面日付変更
            @schedules = current_user.schedules.where(
                work_on: params[:edit_schedule_date]
            ).order(:start_at)
        elsif params[:browsing_user_schedule_date].present? && params[:user_id].present?
            #ユーザー詳細、スケジュール日付変更
            @other_user = User.find_by(public_uid: params[:user_id])
            if @other_user != current_user
                @other_user_schedules = @other_user.schedules.where(
                    work_on: params[:browsing_user_schedule_date]
                ).order(:start_at)
            end
        elsif params[:management_schedule_date].present? && params[:user_id].present?
            #マネージメント、スケジュール日付変更
            @user = User.find_by(public_uid: params[:user_id])
            @schedules = @user.schedules.where(
                work_on: params[:management_schedule_date]
            ).order(:start_at)
        end

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

        if @other_user_schedules.present?
            if @other_user_schedules.last.finish_at[3] == "0"
                @other_user_work_time = (
                    hours_time_change(
                        @other_user_schedules.first.start_at
                    )..hours_time_change(
                        @other_user_schedules.last.finish_at
                    )
                )
            else
                @other_user_work_time = (
                    hours_time_change(
                        @other_user_schedules.first.start_at
                    )..hours_time_change(
                        @other_user_schedules.last.finish_at
                    ) + 1
                )
            end
            @other_user_work_length = @other_user_work_time.to_a.length
            create_other_schedule_arrays(@other_user_schedules, @other_user_work_time)
        end

        respond_to do |format|
            if params[:schedule_date].present?
                format.js { render "schedules/change_schedule" }
            elsif params[:edit_schedule_date].present?
                format.js { render "schedules/change_edit_schedule" }
            elsif params[:browsing_user_schedule_date].present? && params[:user_id].present?
                format.js { render "shared/browsing_other_user_change_date" }
            elsif params[:management_schedule_date].present? && params[:user_id]
                format.js { render "schedules/change_management_schedule" }
            else
                format.any { redirect_to request.referer }
            end
        end
    end

    private

        # 自分の持つミーティングルーム＆ルートパス以外からのアクセス拒否
        def validation_timer_path
            rooms = current_user.meeting_rooms
            url_array = []
            rooms.map{ |room| url_array.push(meeting_room_url(room.public_uid)) }
            unless url_array.include?(request.referer) || root_url == request.referer
                respond_to do |format|
                    format.any { redirect_to root_path }
                end
            end
        end

end
