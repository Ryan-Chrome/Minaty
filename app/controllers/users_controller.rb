class UsersController < ApplicationController
    # schedulesに関するrouteは全てJSフォーマット以外受け付けない
    #　(routesファイル参照)

    # ログインユーザー以外のアクセス拒否
    before_action :authenticate_user!

    # ルートパス以外からのアクセス拒否
    before_action :root_path_limits

    # ユーザー検索結果表示
    def index
        if params[:name].present? && params[:department].present?
            @search_users = User.where(
                name: params[:name],
                department: params[:department]
            )
        elsif params[:name].present?
            @search_users = User.where(name: params[:name])
        elsif params[:department].present?
            @search_users = User.where(department: params[:department])
        end
        respond_to do |format|
            format.js
        end
    end

    # ユーザー詳細表示
    def show
        @other_user = User.find_by(public_uid: params[:id])
        if @other_user.present? && @other_user != current_user
            @other_user_schedules = @other_user.schedules.where(work_on: Date.today).order(:start_at)
            if @other_user_schedules.present?
                if @other_user_schedules.last.finish_at[3] == "0"
                    @other_user_work_time = (hours_time_change(@other_user_schedules.first.start_at)..hours_time_change(@other_user_schedules.last.finish_at))
                else
                    @other_user_work_time = (hours_time_change(@other_user_schedules.first.start_at)..hours_time_change(@other_user_schedules.last.finish_at) + 1)
                end
                @other_user_work_length = @other_user_work_time.to_a.length
                create_other_schedule_arrays(@other_user_schedules, @other_user_work_time)
            end
            
            @status = @other_user.attendances.find_by(
                work_on: Date.today
            )
            @paid_holiday = @other_user.paid_holidays.find_by(
                holiday_on: Date.today
            )
            @other_user_message_ids = current_user.general_message_relations.select(:general_message_id).where(receive_user_id: @other_user.id).or(@other_user.general_message_relations.select(:general_message_id).where(receive_user_id: current_user.id))
            @other_user_messages = GeneralMessage.where(id: @other_user_message_ids).order(created_at: "DESC").page(params[:page]).per(10).reverse
            @other_user_chat_page_count = GeneralMessage.where(id: @other_user_message_ids).page(params[:page]).per(10).total_pages.to_i
            @new_message = GeneralMessage.new
        end
        respond_to do |format|
            format.js
        end
    end

end
