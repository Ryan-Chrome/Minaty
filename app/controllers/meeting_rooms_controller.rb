class MeetingRoomsController < ApplicationController

  # ログインユーザー以外のアクセス拒否
  before_action :authenticate_user!

  # 自分がエントリーしているルーム以外からのアクセス拒否
  before_action :validation_meeting_room_path, only: [:join]

  # 勤怠情報取得
  before_action :get_sidebar_attendance, only: [:show, :index, :past_index, :new]

  # ルーム一覧と過去ルーム一覧以外からのアクセス拒否
  before_action :validation_rooms_path, only: [:destroy]

  def show
    # 対象ルーム取得
    @meeting_room = current_user.meeting_rooms.find_by(public_uid: params[:id])
    if @meeting_room
      # タイマーON
      @timer_on = true
      # お知らせOFF
      @notice_message = true
      # ルームユーザー取得
      @room_users = @meeting_room.users
      # 全ユーザー取得
      @users = User.all
      # ルームメッセージ取得
      @room_messages = @meeting_room.room_messages.includes(:user)
      @new_message = current_user.room_messages.build
      # 新規外部メッセージ
      @new_general_message = current_user.general_messages.build
      # 部署取得
      @departments = Department.where.not(name: "未設定").includes(:users)
      # コンタクトグループ取得
      @contact_groups = current_user.contact_groups.includes(:users)
    else
      redirect_to meeting_rooms_path
    end
  end

  def join # format :js && ajax only
    # 対象ルーム取得
    @meeting_room = current_user.meeting_rooms.find_by(public_uid: params[:id])
    respond_to do |format|
      if @meeting_room
        format.js
      else
        format.any { redirect_to root_path }
      end
    end
  end

  def index
    # 自分の会議前、会議中ルーム取得
    @entry_rooms = current_user.meeting_rooms
    if params[:name].present? && params[:date].present?
      search_date = Date.parse(params[:date])
      @after_entry_rooms = @entry_rooms.where(
        "finish_at > ? AND name = ? AND start_at > ? AND start_at < ?",
        DateTime.now,
        params[:name],
        search_date.beginning_of_day,
        search_date.end_of_day
      ).order(start_at: "ASC").includes(:users)
    elsif params[:name].present?
      @after_entry_rooms = @entry_rooms.where(
        "finish_at > ? AND name = ?",
        DateTime.now,
        params[:name]
      ).order(start_at: "ASC").includes(:users)
    elsif params[:date].present?
      search_date = Date.parse(params[:date])
      @after_entry_rooms = @entry_rooms.where(
        "finish_at > ? AND start_at > ? AND start_at < ?",
        DateTime.now,
        search_date.beginning_of_day,
        search_date.end_of_day
      ).order(start_at: "ASC").includes(:users)
    else
      @after_entry_rooms = @entry_rooms.where(
        "finish_at > ?", DateTime.now
      ).order(start_at: "ASC").includes(:users)
    end
  end

  def past_index
    # 自分の過去のルーム取得
    @entry_rooms = current_user.meeting_rooms
    if params[:name].present? && params[:date].present?
      search_date = Date.parse(params[:date])
      @past_rooms = @entry_rooms.where(
        "finish_at < ? AND name = ? AND start_at > ? AND start_at < ?",
        DateTime.now,
        params[:name],
        search_date.beginning_of_day,
        search_date.end_of_day
      ).order(start_at: "DESC").includes(:users)
    elsif params[:name].present?
      @past_rooms = @entry_rooms.where(
        "finish_at < ? AND name = ?",
        DateTime.now,
        params[:name]
      ).order(start_at: "DESC").includes(:users)
    elsif params[:date].present?
      search_date = Date.parse(params[:date])
      @past_rooms = @entry_rooms.where(
        "finish_at < ? AND start_at > ? AND start_at < ?",
        DateTime.now,
        search_date.beginning_of_day,
        search_date.end_of_day
      ).order(start_at: "DESC").includes(:users)
    else
      @past_rooms = @entry_rooms.where(
        "finish_at < ?", DateTime.now
      ).order(start_at: "DESC").includes(:users)
    end
  end

  # ミーティングルーム新規作成フォーム
  def new
    # 新規ミーティングルーム
    @meeting_room = MeetingRoom.new
    # 全ユーザー取得
    @users = User.all
    # 部署取得
    @departments = Department.where.not(name: "未設定").includes(:users)
    # コンタクトグループ取得
    @contact_groups = current_user.contact_groups.includes(:users)
  end

  # ミーティングルーム新規作成
  def create
    # ルーム日付変換
    room_date = params[:meeting_room][:meeting_date]
    room_date = Date.parse(room_date) if room_date.present?
    # エントリーさせるユーザーを取得
    add_users_id = params[:meeting_room][:room_entry_users]
    entry_users = User.where(
      public_uid: add_users_id
    ).where.not(
      public_uid: current_user.public_uid
    )
    # ミーティングルーム作成
    @meeting_room = MeetingRoom.new(
      name: params[:meeting_room][:name],
      comment: params[:meeting_room][:comment],
      start_at: meeting_start_time,
      finish_at: meeting_end_time,
      meeting_date: room_date,
      room_entry_users: entry_users,
    )
    if @meeting_room.save
      begin
        # ルームにユーザーを追加
        @meeting_room.users << entry_users
        @meeting_room.users << current_user
        # ルーム招待メッセージ時間テキスト用
        start_time = @meeting_room.start_at.strftime("%H:%M")
        end_time = @meeting_room.finish_at.strftime("%H:%M")
        # ルームのコメントによる分岐、招待メッセージ作成
        if @meeting_room.comment.present?
          @general_message = current_user.general_messages.create(
            content: "ミーティングルームを予約しました。
                      議題: #{@meeting_room.name}
                      日付: #{@meeting_room.start_at.strftime("%m月%d日")}
                      時間: #{start_time} ~ #{end_time}
                      コメント:
                      #{@meeting_room.comment}",
            room_id: @meeting_room.public_uid,
          )
        else
          @general_message = current_user.general_messages.create(
            content: "ミーティングルームを予約しました。
                      議題: #{@meeting_room.name}
                      日付: #{@meeting_room.start_at.strftime("%m月%d日")}
                      時間: #{start_time} ~ #{end_time}",
            room_id: @meeting_room.public_uid,
          )
        end
        # 招待メッセージの送信先にエントリーさせるユーザーを追加
        if @general_message.present?
          @general_message.receive_users << entry_users
        end
        # ミーティングルーム一覧へリダイレクト
        redirect_to meeting_rooms_path
      rescue
        create_render
      end
    else
      create_render
    end
  end

  # ミーティングルーム削除
  def destroy
    # 対象ルーム削除
    room = current_user.meeting_rooms.find_by(public_uid: params[:id])
    if room
      room.destroy
    end
    redirect_to request.referer
  end

  private

  # ルーム新規作成、開始時間変換
  def meeting_start_time
    hours = params[:meeting_room]["start_at(4i)"]
    minutes = params[:meeting_room]["start_at(5i)"]
    if hours_check(hours) && minutes_check(minutes)
      start = hours + ":" + minutes
      start_tm = params[:meeting_room][:meeting_date] + " " + start
      return start_tm
    else
      return false
    end
  end

  # ルーム新規作成、終了時間変換
  def meeting_end_time
    hours = params[:meeting_room]["finish_at(4i)"]
    minutes = params[:meeting_room]["finish_at(5i)"]
    if hours_check(hours) && minutes_check(minutes)
      finish = hours + ":" + minutes
      end_tm = params[:meeting_room][:meeting_date] + " " + finish
      return end_tm
    else
      return false
    end
  end

  # ルーム新規作成時レンダリング
  def create_render
    @users = User.all
    @departments = Department.where.not(name: "未設定").includes(:users)
    @contact_groups = current_user.contact_groups.includes(:users)
    render "new"
  end

  # ルーム一覧と過去ルーム一覧以外からのアクセス拒否
  def validation_rooms_path
    unless request.referer == meeting_rooms_url || request.referer == meeting_rooms_past_index_url
      redirect_to root_path
    end
  end
end
