require 'rails_helper'

RSpec.describe "Entry", type: :request do

    let!(:user){ create(:user) }
    let!(:other_user){ create(:other_user) }
    let!(:therd_user){ create(:therd_user) }
    let!(:meeting_room){ create(:meeting_room) }
    let!(:entry){ meeting_room.entries.create(user_id: user.id) }
    let!(:other_room){ create(:meeting_room) }

    # ミーティングルームへの招待
    describe "POST #create" do
        let(:entry_params){ {"entry"=>{"user_id"=>"#{other_user.public_uid}", "meeting_room_id"=>"#{meeting_room.public_uid}"}} }
        let(:invalid_room){ {"entry"=>{"user_id"=>"#{other_user.public_uid}", "meeting_room_id"=>"invalid"}} }
        let(:invalid_user){ {"entry"=>{"user_id"=>"invalid", "meeting_room_id"=>"#{meeting_room.public_uid}"}} }
        let(:invalid_other_room){ {"entry"=>{"user_id"=>"#{other_user.public_uid}", "meeting_room_id"=>"#{other_room.public_uid}"}} }
        # ログイン済みユーザー
        context "user is logged in" do
            before do
                sign_in user
            end

            context "Request" do
                # 有効なパラメータ
                it "Success js format" do
                    post entries_path, params: entry_params, xhr: true
                    expect(response.status).to eq 200
                end

                # JS形式以外のリクエストは例外になること
                it "Error from html format" do
                    expect do
                        post entries_path, params: entry_params
                    end.to raise_error(ActionController::RoutingError)
                end
            end

            context "Create" do
                # 有効なパラメータ
                it "Success valid params" do
                    expect do
                        post entries_path, params: entry_params, xhr: true
                    end.to change { Entry.count }.by(1)
                end

                # 無効なパラメータ(room_id)
                it "Error invalid room" do
                    expect do
                        post entries_path, params: invalid_room, xhr: true
                    end.to change { Entry.count }.by(0)
                end

                # 無効なパラメータ(user_id)
                it "Error invalid user" do
                    expect do
                        post entries_path, params: invalid_user, xhr: true
                    end.to change { Entry.count }.by(0)
                end

                # 無効なパラメータ(other_room_id)
                it "Error invalid other_room" do
                    expect do
                        post entries_path, params: invalid_other_room, xhr: true
                    end.to change { Entry.count }.by(0)
                end
            end
        end
    end

end