class EntriesController < ApplicationController
    # entriesに関するrouteは全てJSフォーマット以外受け付けない
    #　(routesファイル参照)

    # ログインユーザー以外のアクセス拒否
    before_action :authenticate_user!

    # ミーティングへの招待
    def create
        @entry_add_user = User.find_by(public_uid: params[:entry][:user_id])
        @meeting_room = current_user.meeting_rooms.find_by(
            public_uid: params[:entry][:meeting_room_id]
        )
        if @meeting_room && @entry_add_user
            @entry = @meeting_room.entries.build(user_id: @entry_add_user.id)
            if @entry.save
                @general_message = current_user.general_messages.build(
                    content: "ルームに招待されました。
                    議題: #{@meeting_room.name}",
                    room_id: @meeting_room.public_uid
                )
                if @general_message.save
                    current_user.general_message_relations.create(
                        receive_user_id: @entry_add_user.id,
                        general_message_id: @general_message.id
                    )
                end
                ActionCable.server.broadcast "room_channel_#{@meeting_room.public_uid}",
                    user_list_content: render_user_list_content(@entry_add_user),
                    invitation_user_list_content: @entry_add_user.public_uid
            end
        end
        respond_to do |format|
            format.js
        end
    end

    private

        # ルームのユーザーリストに追加するテンプレートをレンダリング
        def render_user_list_content(user)
            ApplicationController.renderer.render partial: 'entries/room_user_list_content', locals: { user: user }
        end
        
end
