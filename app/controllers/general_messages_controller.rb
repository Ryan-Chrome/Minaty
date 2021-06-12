class GeneralMessagesController < ApplicationController

  # ログインユーザー以外のアクセス拒否
  before_action :authenticate_user!

  # ルートパス以外からのアクセス拒否
  before_action :root_path_limits, only: [:show, :create, :message_ajax, :home_message_ajax]

  # ルートパス＆自分の持つミーティングルーム以外からのアクセス拒否
  before_action :validation_root_and_meeting, only: [:multiple_create]

  def show # format :js && ajax only
    # メッセージ取得
    general_message = current_user.general_messages.find_by(id: params[:id])
    if general_message
      # メッセージの送信先ユーザー取得
      @receive_users = general_message.receive_users
    end
  end

  def create # format :js && ajax only
    # 送信先ユーザー取得
    send_user = User.find_by(
      public_uid: params[:general_message][:receive_user_id],
    )
    if send_user && send_user != current_user
      # メッセージ作成
      @general_message = current_user.general_messages.build(
        general_message_params
      )
      if @general_message.save
        begin
          # 送信先に追加
          @general_message.receive_users << send_user
          # 送信先取得
          @receive_users = @general_message.receive_users
        rescue
          @general_message.destroy
        end
      end
    end
  end

  def multiple_create # format :js && ajax only
    # 送信先ユーザー取得(current_user以外)
    send_users = User.where(
      public_uid: params[:general_message_send_users],
    ).where.not(
      public_uid: current_user.public_uid,
    )
    if send_users.present?
      # メッセージ作成
      @general_message = current_user.general_messages.build(
        general_message_params
      )
      if @general_message.save
        begin
          # メッセージ送信先追加
          @general_message.receive_users << send_users
          @receive_users = @general_message.receive_users
        rescue
          @general_message.destroy
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
  def message_ajax # ajax only
    # 対象ユーザー取得
    @other_user = User.find_by(public_uid: params[:other_user])
    if @other_user && @other_user != current_user
      # 対象ユーザー宛のメッセージ取得
      current_messages = current_user.general_messages.includes(
        :general_message_relations
      ).where(
        general_message_relations: {
          user_id: @other_user.id,
        },
      )
      # 対象ユーザーからcurrent_userへのメッセージ取得
      other_messages = @other_user.general_messages.includes(
        :general_message_relations
      ).where(
        general_message_relations: {
          user_id: current_user.id,
        },
      )
      # 対象メッセージID取得
      @other_user_messages_ids = current_messages.ids + other_messages.ids
      # 対象メッセージ取得
      @other_user_messages = GeneralMessage.where(
        id: @other_user_messages_ids,
      ).includes(:user).order(created_at: "DESC").page(params[:page]).per(10).reverse
    end
    respond_to do |format|
      format.js
    end
  end

  # ホームチャットコンテンツの読み込み(スクロール時)
  def home_message_ajax # ajax only
    # 対象メッセージID取得
    @message_ids = current_user.general_message_ids + current_user.receive_message_ids
    # 対象メッセージ取得
    @messages = GeneralMessage.where(
      id: @message_ids,
    ).includes(
      :user, :receive_users
    ).order(created_at: "DESC").page(params[:page]).per(10).reverse
    respond_to do |format|
      format.js
    end
  end

  private

  # ストロングパラメータ
  def general_message_params
    params.require(:general_message).permit(:content)
  end
end
