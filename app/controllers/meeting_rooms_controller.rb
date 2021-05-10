class MeetingRoomsController < ApplicationController

    # ログインユーザー以外のアクセス拒否
    before_action :authenticate_user!

    # ミーティングルーム表示
    def show
        @meeting_room = current_user.meeting_rooms.find_by(public_uid: params[:id])
        if @meeting_room
            @room_users = @meeting_room.users
            @users = User.all
            @room_messages = @meeting_room.room_messages
            @new_message = current_user.room_messages.build
            @new_general_message = current_user.general_messages.build
            @departments = User.select(:department).distinct
            @contact_groups = current_user.contact_groups
            @timer_on = "on"
        else
            redirect_to meeting_rooms_path
        end
    end

    # ミーティングルーム参加
    def join
        @meeting_room = current_user.meeting_rooms.find_by(public_uid: params[:id])
        respond_to do |format|
            if @meeting_room
                format.js
            else
                format.any { redirect_to root_path }
            end
        end
    end

    # ミーティング一覧
    def index
        @entry_rooms = current_user.meeting_rooms
        if params[:name].present? && params[:date].present?
            search_date = Date.parse(params[:date])
            @after_entry_rooms = @entry_rooms.where(
                "finish_at > ? AND name = ? AND start_at > ? AND start_at < ?",
                DateTime.now,
                params[:name],
                search_date.beginning_of_day,
                search_date.end_of_day
            ).order(start_at: "ASC")
        elsif params[:name].present?
            @after_entry_rooms = @entry_rooms.where(
                "finish_at > ? AND name = ?",
                DateTime.now,
                params[:name]
            ).order(start_at: "ASC")
        elsif params[:date].present?
            search_date = Date.parse(params[:date])
            @after_entry_rooms = @entry_rooms.where(
                "finish_at > ? AND start_at > ? AND start_at < ?",
                DateTime.now,
                search_date.beginning_of_day,
                search_date.end_of_day
            ).order(start_at: "ASC")
        else
            @after_entry_rooms = @entry_rooms.where(
                "finish_at > ?", DateTime.now
            ).order(start_at: "ASC")
        end
    end

    # 過去のミーティングルーム一覧
    def past_index
        @entry_rooms = current_user.meeting_rooms
        if params[:name].present? && params[:date].present?
            search_date = Date.parse(params[:date])
            @past_rooms = @entry_rooms.where(
                "finish_at < ? AND name = ? AND start_at > ? AND start_at < ?",
                DateTime.now,
                params[:name],
                search_date.beginning_of_day,
                search_date.end_of_day
            ).order(start_at: "DESC")
        elsif params[:name].present?
            @past_rooms = @entry_rooms.where(
                "finish_at < ? AND name = ?",
                DateTime.now,
                params[:name]
            ).order(start_at: "DESC")
        elsif params[:date].present?
            search_date = Date.parse(params[:date])
            @past_rooms = @entry_rooms.where(
                "finish_at < ? AND start_at > ? AND start_at < ?",
                DateTime.now,
                search_date.beginning_of_day,
                search_date.end_of_day
            ).order(start_at: "DESC")
        else
            @past_rooms = @entry_rooms.where(
                "finish_at < ?", DateTime.now
            ).order(start_at: "DESC")
        end
    end

    # ミーティングルーム新規作成フォーム
    def new
        @meeting_room = MeetingRoom.new
        @users = User.all
        @departments = User.select(:department).distinct
        @contact_groups = current_user.contact_groups
    end

    # ミーティングルーム新規作成
    def create
        @users = User.all
        @departments = User.select(:department).distinct
        @contact_groups = current_user.contact_groups

        room_date = params[:meeting_room][:meeting_date]
        room_date = Date.parse(room_date) if room_date.present?
        entries = params[:meeting_room][:room_entry_users]
        if entries.present?
            entries.map!{ |entry| User.find_by(public_uid: entry) }
        end

        @meeting_room = MeetingRoom.new(
            name: params[:meeting_room][:name],
            comment: params[:meeting_room][:comment],
            start_at: meeting_start_time,
            finish_at: meeting_end_time,
            meeting_date: room_date,
            room_entry_users: entries
        )

        if @meeting_room.valid?
            @meeting_room.save
            start_time = @meeting_room.start_at.strftime("%H:%M")
            end_time = @meeting_room.finish_at.strftime("%H:%M")

            if @meeting_room.comment.present?
                @general_message = current_user.general_messages.create(
                    content: "ミーティングルームを予約しました。
                    議題: #{@meeting_room.name}
                    日付: #{@meeting_room.start_at.strftime("%m月%d日")}
                    時間: #{start_time} ~ #{end_time}
                    コメント:
                    #{@meeting_room.comment}",
                    room_id: @meeting_room.public_uid
                )
            else
                @general_message = current_user.general_messages.create(
                    content: "ミーティングルームを予約しました。
                    議題: #{@meeting_room.name}
                    日付: #{@meeting_room.start_at.strftime("%m月%d日")}
                    時間: #{start_time} ~ #{end_time}",
                    room_id: @meeting_room.public_uid
                )
            end

            @meeting_room.entries.create(user_id: current_user.id)
            entries.each do |user|
                @meeting_room.entries.create(user_id: user.id)
                current_user.general_message_relations.create(
                    receive_user_id: user.id,
                    general_message_id: @general_message.id
                )
            end
            redirect_to meeting_rooms_path
        else
            render "new"
        end
    end

    def destroy
        
    end

    private

        def meeting_start_time
            hours = params[:meeting_room]["start_at(4i)"]
            minutes = params[:meeting_room]["start_at(5i)"]
            if hours_check(hours) && minutes_check(minutes)
                start = hours + ":" + minutes
                start_tm = params[:meeting_room][:meeting_date] + " " + start;
                return start_tm
            else
                return false
            end
        end

        def meeting_end_time
            hours = params[:meeting_room]["finish_at(4i)"]
            minutes = params[:meeting_room]["finish_at(5i)"]
            if hours_check(hours) && minutes_check(minutes)
                finish = hours + ":" + minutes
                end_tm = params[:meeting_room][:meeting_date] + " " + finish;
                return end_tm
            else
                return false
            end
        end

end
