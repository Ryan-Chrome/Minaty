class RoomMessagesController < ApplicationController

    # room_messagesに関するrouteは全てJSフォーマット以外受け付けない
    #　(routesファイル参照)

    # ログインユーザー以外のアクセス拒否
    before_action :authenticate_user!

    # ルームメッセージ新規作成
    def create
        @meeting_room = current_user.meeting_rooms.find_by(
            public_uid: params[:room_message][:meeting_room_id]
        )
        if @meeting_room
            @room_message = current_user.room_messages.create(
                meeting_room_id: @meeting_room.id,
                content: params[:room_message][:content]
            )
        end
        respond_to do |format|
            format.js
        end
    end
end
