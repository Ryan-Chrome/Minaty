class RoomMessagesController < ApplicationController

  # ログインユーザー以外のアクセス拒否
  before_action :authenticate_user!

  # 自分がエントリーしているルーム以外からのアクセス拒否
  before_action :validation_meeting_room_path

  def create # format :js && ajax only
    # 対象ルーム取得
    @meeting_room = current_user.meeting_rooms.find_by(
      public_uid: params[:room_message][:meeting_room_id],
    )
    if @meeting_room
      # ルームメッセージ作成
      @room_message = current_user.room_messages.create(
        meeting_room_id: @meeting_room.id,
        content: params[:room_message][:content],
      )
    end
  end
end
