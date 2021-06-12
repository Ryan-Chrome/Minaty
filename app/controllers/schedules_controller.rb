class SchedulesController < ApplicationController

  # ログインユーザー以外のアクセス拒否
  before_action :authenticate_user!

  # ルートパス以外からのアクセス拒否
  before_action :root_path_limits, only: [:new, :meeting_new, :edit, :update, :destroy]

  # ルートパス＆自分のエントリーしているミーティングルーム以外からのアクセス拒否
  before_action :validation_root_and_meeting, only: [:add_timer, :create]

  def new # format :js && ajax only
    # スケジュール新規作成
    @schedule = current_user.schedules.build
    # スケジュール新規作成日付
    @new_schedule_date = "#{params[:add_date].to_date}"
    # 新規作成日付のスケジュール全て取得
    @schedules = current_user.schedules.where(
      work_on: @new_schedule_date,
    ).order(:start_at)
    if @schedules.present?
      # スケジュール表用配列作成
      schedule_table_create(@schedules)
    end
  end

  def meeting_new # format :js && ajax only
    # ミーティングルーム取得
    @meeting_room = current_user.meeting_rooms.find_by(
      public_uid: params[:meeting_room_id],
    )
    if @meeting_room
      # スケジュール新規作成
      @schedule = current_user.schedules.build
      # スケジュール新規作成日付
      @new_schedule_date = "#{@meeting_room.start_at.strftime("%Y-%m-%d")}"
      # 新規作成日付のスケジュール全て取得
      @schedules = current_user.schedules.where(
        work_on: @new_schedule_date,
      ).order(:start_at)
      if @schedules.present?
        # スケジュール表用配列作成
        schedule_table_create(@schedules)
      end
    end
  end

  def add_timer # format :js && ajax only
    # タイマーからの時間取得
    @start_hours = params[:start_time][0..1]
    @start_minutes = "#{params[:start_time][3..4].to_i.round(-1)}"
    @end_hours = params[:end_time][0..1]
    @end_minutes = "#{params[:end_time][3..4].to_i.round(-1)}"
    if @start_minutes == "0" || @start_minutes == "60"
      if @start_minutes == "60"
        @start_hours = "#{@start_hours.to_i + 1}"
      end
      @start_minutes = "00"
    end
    if @start_hours == "24"
      @start_hours = "23"
      @start_minutes = "50"
    end
    if @end_minutes == "0" || @end_minutes == "60"
      if @end_minutes == "60"
        @end_hours = "#{@end_hours.to_i + 1}"
      end
      @end_minutes = "00"
    end
    # 取得時間チェック
    if schedule_hours_params_check(@start_hours) \
      && schedule_minutes_params_check(@start_minutes) \
      && schedule_hours_params_check(@end_hours) \
      && schedule_minutes_params_check(@end_minutes)
      # スケジュールの開始時間と終了時間定義
      add_start_time = @start_hours + @start_minutes
      add_end_time = @end_hours + @end_minutes
      # 開始時間が終了時間より遅い場合、24時に終了時間を設定
      if add_start_time > add_end_time
        @end_hours = "24"
        @end_minutes = "00"
      end
      # スケジュール日付定義
      @new_schedule_date = Date.today
      # スケジュール新規作成
      @schedule = current_user.schedules.build
      # 新規作成日付のスケジュール全て取得
      @schedules = current_user.schedules.where(
        work_on: @new_schedule_date,
      ).order(:start_at)
      if @schedules.present?
        # スケジュール表用配列作成
        schedule_table_create(@schedules)
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

  def create # format :js && ajax only
    # スケジュールの開始時間と終了時間定義
    add_start_time =
      params[:schedule]["start_at(4i)"] + ":" + params[:schedule]["start_at(5i)"]
    add_end_time =
      params[:schedule]["finish_at(4i)"] + ":" + params[:schedule]["finish_at(5i)"]
    start_time = add_start_time.delete("^0-9").to_i
    end_time = add_end_time.delete("^0-9").to_i
    # 登録しようとしている日付のスケジュールを取得
    @schedules = current_user.schedules.where(
      work_on: params[:schedule][:work_on],
    ).order(:start_at)
    # 登録しようとしている日付の全スケジュール時間を配列作成
    registered_time = []
    @schedules.each do |schedule|
      registered_start_time = (schedule.start_at.delete("^0-9").to_i) + 1
      registered_end_time = (schedule.finish_at.delete("^0-9").to_i) - 1
      registered_time.concat(
        (registered_start_time..registered_end_time).to_a
      )
    end
    # 上記の配列に登録しようとしているスケジュールの時間が存在しないか確認
    unless registered_time.any?(start_time..end_time)
      # スケジュール新規作成
      schedule = current_user.schedules.build(
        work_on: params[:schedule][:work_on],
        name: params[:schedule][:name],
        start_at: add_start_time,
        finish_at: add_end_time,
      )
      if schedule.save
        # 新規作成したスケジュールの日付定義
        @new_schedule_date = schedule.work_on
        # スケジュール再取得
        @schedules.reload
        # スケジュール表用配列作成
        schedule_table_create(@schedules)
        # スケジュール新規作成
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

  def edit # format :js && ajax only
    # 対象スケジュール取得
    @schedule = current_user.schedules.find_by(id: params[:id])
    if @schedule.present?
      # 対象スケジュールのスケジュール全て取得
      @schedules = current_user.schedules.where(
        work_on: @schedule.work_on,
      ).order(:start_at)
      # スケジュール表用配列作成
      schedule_table_create(@schedules)
    end
  end

  def update # format :js && ajax only
    # 対象スケジュール取得
    @schedule = current_user.schedules.find_by(id: params[:id])
    if @schedule.present?
      # スケジュールの開始時間と終了時間定義
      edit_start_time =
        params[:schedule]["edit_start_at(4i)"] + ":" + params[:schedule]["edit_start_at(5i)"]
      edit_end_time =
        params[:schedule]["edit_finish_at(4i)"] + ":" + params[:schedule]["edit_finish_at(5i)"]
      start_time = edit_start_time.delete("^0-9").to_i
      end_time = edit_end_time.delete("^0-9").to_i
      # 更新しようとしている日付のスケジュールを取得
      @schedules = current_user.schedules.where(
        work_on: @schedule.work_on,
      ).order(:start_at)
      # 更新しようとしている日付の全スケジュール時間を配列作成
      registered_time = []
      @schedules.each do |schedule|
        if schedule != @schedule
          registered_start_time = (schedule.start_at.delete("^0-9").to_i) + 1
          registered_end_time = (schedule.finish_at.delete("^0-9").to_i) - 1
          registered_time.concat((registered_start_time..registered_end_time).to_a)
        end
      end
      # 上記の配列に登録しようとしているスケジュールの時間が存在しないか確認
      unless registered_time.any?(start_time..end_time)
        @schedule.update(
          name: params[:schedule][:name],
          start_at: edit_start_time,
          finish_at: edit_end_time,
        )
        if @schedule.valid?
          # スケジュール再取得
          @schedules.reload
          # スケジュール表用配列作成
          schedule_table_create(@schedules)
        end
      end
    end
  end

  def destroy # format :js && ajax only
    # 対象スケジュール取得
    @destroy_schedule = current_user.schedules.find_by(id: params[:id])
    if @destroy_schedule.present?
      # スケジュール削除
      @destroy_schedule.destroy
      # 対象スケジュールの日付と同じ日付のスケジュールを取得
      @schedules = current_user.schedules.where(
        work_on: @destroy_schedule.work_on,
      ).order(:start_at)
      if @schedules.present?
        # スケジュール表用配列作成
        schedule_table_create(@schedules)
      end
    end
  end

  def date_change # format :js && ajax only
    if params[:schedule_date].present?
      #ホーム、スケジュール日付変更
      @schedules = current_user.schedules.where(
        work_on: params[:schedule_date],
      ).order(:start_at)
    elsif params[:edit_schedule_date].present?
      #スケジュール編集画面日付変更
      @schedules = current_user.schedules.where(
        work_on: params[:edit_schedule_date],
      ).order(:start_at)
    elsif params[:browsing_user_schedule_date].present? && params[:user_id].present?
      #ユーザー詳細、スケジュール日付変更
      @other_user = User.find_by(public_uid: params[:user_id])
      if @other_user != current_user
        @other_user_schedules = @other_user.schedules.where(
          work_on: params[:browsing_user_schedule_date],
        ).order(:start_at)
      end
    elsif params[:management_schedule_date].present? && params[:user_id].present?
      #マネージメント、スケジュール日付変更
      @user = User.find_by(public_uid: params[:user_id])
      @schedules = @user.schedules.where(
        work_on: params[:management_schedule_date],
      ).order(:start_at)
    end
    if @schedules.present?
      # スケジュール表用配列作成
      schedule_table_create(@schedules)
    end
    if @other_user_schedules.present?
      # スケジュール表用配列作成
      if @other_user_schedules.last.finish_at[3] == "0"
        @other_user_work_time = (hours_time_change(
          @other_user_schedules.first.start_at
        )..hours_time_change(
          @other_user_schedules.last.finish_at
        ))
      else
        @other_user_work_time = (hours_time_change(
          @other_user_schedules.first.start_at
        )..hours_time_change(
          @other_user_schedules.last.finish_at
        ) + 1)
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
        format.js { render "schedules/change_other_user_schedule" }
      elsif params[:management_schedule_date].present? && params[:user_id]
        format.js { render "schedules/change_management_schedule" }
      else
        format.any { redirect_to request.referer }
      end
    end
  end

  private

  # スケジュール表用配列作成
  def schedule_table_create(schedules)
    if schedules.last.finish_at[3] == "0"
      @work_time = (hours_time_change(
        schedules.first.start_at
      )..hours_time_change(
        schedules.last.finish_at
      ))
    else
      @work_time = (hours_time_change(
        schedules.first.start_at
      )..hours_time_change(
        schedules.last.finish_at
      ) + 1)
    end
    @work_length = @work_time.to_a.length
    create_schedule_arrays(schedules, @work_time)
  end
end
