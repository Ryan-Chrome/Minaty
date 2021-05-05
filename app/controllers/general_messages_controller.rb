class GeneralMessagesController < ApplicationController
    # general_messagesに関するrouteはメッセージ読み込みアクションを除いて、JSフォーマット以外を受け付けない
    #　(routesファイル参照)

    # ログインユーザー以外のアクセス拒否
    before_action :authenticate_user!

    # ルートパス以外からのアクセス拒否
    before_action :root_path_limits, only:[:show, :create, :message_ajax, :home_message_ajax]

    # ルートパス＆自分の持つミーティングルーム以外からのアクセス拒否
    before_action :validation_root_and_meeting, only:[:multiple_create]

    # メッセージの送信先一覧表示
    def show
        general_message = current_user.general_messages.find_by(id: params[:id])
        if general_message
            receive_user_ids = general_message.general_message_relations.select(:receive_user_id)
            @receive_users = User.where(id: receive_user_ids)
        end
        respond_to do |format|
            format.js
        end
    end

    # メッセージ新規作成
    def create
        send_user = User.find_by(public_uid: params[:general_message][:receive_user_id])
        if send_user && send_user != current_user
            @general_message = current_user.general_messages.create(general_message_params)
            if @general_message
                current_user.general_message_relations.create(receive_user_id: send_user.id, general_message_id: @general_message.id )
                @current_user_send_message = @general_message.general_message_relations
            end
        end
        respond_to do |format|
            format.js 
        end
    end

    # 複数人宛にメッセージを新規作成(複数人でなくても可)
    def multiple_create
        if params[:general_message_send_users].present?
            if !params[:general_message_send_users].include?(current_user.id.to_s)
                @general_message = current_user.general_messages.create(general_message_params)
                if @general_message.valid?
                    send_users = User.where(public_uid: params[:general_message_send_users])
                    send_users.each do |user|
                        current_user.general_message_relations.create(receive_user_id: user.id, general_message_id: @general_message.id)
                    end
                    @current_user_send_message = @general_message.general_message_relations
                end
            end
        end
        respond_to do |format|
            if root_url == request.referer
                format.js
            else
                format.js { render "general_messages/room_inside_create" }
            end
        end
    end

    # ユーザー詳細ページのチャットコンテンツの読み込み(スクロール時)
    def message_ajax
        @other_user = User.find_by(public_uid: params[:other_user])
        @other_user_messages_ids = current_user.general_message_relations.select(:general_message_id).where(receive_user_id: @other_user.id).or(@other_user.general_message_relations.select(:general_message_id).where(receive_user_id: current_user.id))
        @other_user_messages = GeneralMessage.where(id: @other_user_messages_ids).order(created_at: "DESC").page(params[:page]).per(10).reverse
        respond_to do |format|
            format.html
        end
    end

    # ホームチャットコンテンツの読み込み(スクロール時)
    def home_message_ajax
        @message_ids = current_user.reverse_message_relations.select(:general_message_id).distinct.or(current_user.general_message_relations.select(:general_message_id).distinct)
        @messages = GeneralMessage.where(id: @message_ids).order(created_at: "DESC").page(params[:page]).per(10).reverse
        @page_count = GeneralMessage.where(id: @message_ids).page(params[:page]).per(10).total_pages.to_i
        respond_to do |format|
            format.html
        end
    end

    private

        # ストロングパラメータ
        def general_message_params
            params.require(:general_message).permit(:content)
        end

        # 自分の持つミーティングルーム＆ルートパス以外からのアクセス拒否
        def validation_root_and_meeting
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
