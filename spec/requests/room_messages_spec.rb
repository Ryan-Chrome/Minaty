require 'rails_helper'

RSpec.describe "RoomMessage", type: :request do

    let!(:user){ create(:user) }
    let!(:other_user){ create(:other_user) }
    let!(:meeting_room){ create(:meeting_room) }
    let!(:entry){ meeting_room.entries.create(user_id: user.id) }
    let!(:other_room){ create(:meeting_room) }

    # ルームメッセージ新規作成
    describe "POST #create" do
        let(:message_params){ {"room_message"=>{"meeting_room_id"=>"#{meeting_room.public_uid}", "content"=>"テストテキスト"}} }
        let(:invalid_room_id){ {"room_message"=>{"meeting_room_id"=>"#{other_room.public_uid}", "content"=>"テストテキスト"}} }
        let(:invalid_content){ {"room_message"=>{"meeting_room_id"=>"#{meeting_room.public_uid}", "content"=>"#{a * 401}"}} }
        # ログイン済みユーザー
        context "user is logged in" do
            before do
                sign_in user
            end

            context "Request" do
                # 有効なパラメータ(JS形式)
                let "Success js format" do
                    post room_messages_path, params: message_params, xhr: true
                    expect(response.status).to eq 200
                end

                # JS形式以外のリクエストは例外になること
                it "Error from html format" do
                    expect do
                        post room_messages_path, params: message_params
                    end.to raise_error(ActionController::RoutingError)
                end
            end

            context "Create" do
                # 有効なパラメータ
                let "Success valid params" do
                    expect do
                        post room_messages_path, params: message_params, xhr: true
                    end.to change { RoomMessage.count }.by(1)
                end

                # 無効なパラメータ(room_id)
                let "Error invalid room" do
                    expect do
                        post room_messages_path, params: invalid_room_id, xhr: true
                    end.to change { RoomMessage.count }.by(0)
                end

                # 無効なパラメータ(content)
                let "Error invalid content" do
                    expect do
                        post room_messages_path, params: invalid_content, xhr: true
                    end.to change { RoomMessage.count }.by(0)
                end
            end
        end
    end

end