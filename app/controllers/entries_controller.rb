class EntriesController < ApplicationController

  # ログインユーザー以外のアクセス拒否
  before_action :authenticate_user!

  # 自分がエントリーしているルーム以外からのアクセス拒否
  before_action :validation_meeting_room_path

  def create # format :js && ajax only
    # 追加ユーザー取得
    @entry_add_user = User.find_by(
      public_uid: params[:entry][:user_id]
    )
    # 対象ルーム取得
    @meeting_room = current_user.meeting_rooms.find_by(
      public_uid: params[:entry][:meeting_room_id],
    )
    if @meeting_room && @entry_add_user
      begin
        # 対象ルームにユーザー追加
        @entry = @meeting_room.users << @entry_add_user
        # 招待メッセージ作成
        @general_message = current_user.general_messages.build(
          content: "ルームに招待しました。
                    議題: #{@meeting_room.name}",
          room_id: @meeting_room.public_uid,
        )
        if @general_message.save
          # メッセージの送信先に対象ユーザーを追加
          @general_message.receive_users << @entry_add_user
        end
        # 追加ユーザーチャンネルへメッセージ送信
        ActionCable.server.broadcast "room_channel_#{@meeting_room.public_uid}",
                                     user_list_content: render_user_list_content(@entry_add_user),
                                     invitation_user_list_content: @entry_add_user.public_uid
      rescue
        respond_to do |format|
          format.js
        end
      end
    end
  end

  private

  # ルームのユーザーリストに追加するテンプレートをレンダリング
  def render_user_list_content(user)
    ApplicationController.renderer.render partial: "entries/room_user_list_content", locals: { user: user }
  end
end
