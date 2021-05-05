require 'rails_helper'

RSpec.describe "MeetingRoom", type: :request do

    let!(:user){ create(:user) }
    let!(:other_user){ create(:other_user) }
    let!(:therd_user){ create(:therd_user) }
    
    # ミーティングルーム表示
    describe "GET #show" do
        let!(:meeting_room){ create(:meeting_room) }
        let!(:entry){ meeting_room.entries.create(user_id: user.id) }
        let!(:other_meeting_room){ create(:meeting_room) }
        # ログイン済みユーザー
        context "user is logged in" do
            before do
                sign_in user
            end

            context "Request" do
                # エントリー済みのミーティングルームにアクセス
                it "Success my_meeting_room" do
                    get meeting_room_path(meeting_room.public_uid)
                    expect(response.status).to eq 200
                end

                # エントリーしていないミーティングルーム
                it "Error other_meeting_room" do
                    get meeting_room_path(other_meeting_room.public_uid)
                    expect(response.status).to eq 302
                    expect(response).to redirect_to meeting_rooms_path
                end
            end

            context "Response" do
                # ミーティング時間中もしくは前の場合
                it "meeting_room" do
                    get meeting_room_path(meeting_room.public_uid)
                    expect(response.body).to include("プレビュー")
                end
            end
        end
    end

    # ミーティングルーム参加
    describe "GET #join" do
        let!(:meeting_room){ create(:meeting_room) }
        let!(:entry){ meeting_room.entries.create(user_id: user.id) }
        let(:meeting_room_header){ { "HTTP_REFERER" => meeting_room_url(meeting_room.public_uid) } }
        let!(:other_meeting_room){ create(:meeting_room) }
        # ログイン済みユーザー
        context "user is logged in" do
            before do
                sign_in user
            end

            context "Request" do
                # エントリー済みのミーティングルームからのリクエスト(js形式)
                it "Success from my_meeting_room(js)" do
                    get meeting_rooms_join_path(meeting_room.public_uid), headers: meeting_room_header, xhr: true
                    expect(response.status).to eq 200
                end
    
                # エントリー済みのミーティングルームからのリクエスト(js形式以外)
                it "Error from my_meeting_room(not_js)" do
                    expect do
                        get meeting_rooms_join_path(meeting_room.public_uid), headers: meeting_room_header
                    end.to raise_error(ActionController::RoutingError)
                end
    
                # ユーザーの持つミーティングルームID以外を含めたパスが送られた場合
                it "Error path containing other_meeting_room_id" do
                    get meeting_rooms_join_path(other_meeting_room.public_uid), headers: meeting_room_header, xhr: true
                    expect(response.status).to eq 302
                    expect(response).to redirect_to root_path
                end
            end
        end
    end

    # ミーティング一覧
    describe "GET #index" do
        let!(:meeting_room){ create(:meeting_room) }
        let!(:entry){ meeting_room.entries.create(user_id: user.id) }
        let!(:other_meeting_room){ create(:meeting_room, name: "other_room") }
        # ログイン済みユーザー
        context "user is logged in" do
            before do
                sign_in user
            end

            # リクエスト
            it "Request success" do
                get meeting_rooms_path
                expect(response.status).to eq 200
            end

            # 自分のルームを表示
            it "Display my_meeting_rooms" do
                get meeting_rooms_path
                expect(response.body).to include("meeting_room", "10月09日")
            end
        end
    end
    
    # ミーティングルーム新規作成フォーム
    describe "GET #new" do
        # ログイン済みユーザー
        context "user is logged in" do
            before do
                sign_in user
            end

            # リクエスト
            it "Request success" do
                get new_meeting_room_path
                expect(response.status).to eq 200
            end
        end
    end

    # ミーティングルーム新規作成
    describe "POST #create" do
        let(:meeting_room_params){
            {"meeting_room"=>{
                "name"=>"テスト会議",
                "start_at(4i)"=>"10",
                "start_at(5i)"=>"00",
                "finish_at(4i)"=>"17",
                "finish_at(5i)"=>"00",
                "meeting_date"=>"2021-10-01",
                "room_entry_users"=>["#{other_user.public_uid}", "#{therd_user.public_uid}"]
            }}
        }
        let(:invalid_name_params){
            {"meeting_room"=>{
                "name"=>"",
                "start_at(4i)"=>"10",
                "start_at(5i)"=>"00",
                "finish_at(4i)"=>"17",
                "finish_at(5i)"=>"00",
                "meeting_date"=>"2021-10-01",
                "room_entry_users"=>["0", "1"]
            }}
        }
        let(:invalid_start_params){
            {"meeting_room"=>{
                "name"=>"",
                "start_at(4i)"=>"",
                "start_at(5i)"=>"00",
                "finish_at(4i)"=>"17",
                "finish_at(5i)"=>"00",
                "meeting_date"=>"2021-10-01",
                "room_entry_users"=>["0", "1"]
            }}
        }
        let(:invalid_end_params){
            {"meeting_room"=>{
                "name"=>"",
                "start_at(4i)"=>"10",
                "start_at(5i)"=>"00",
                "finish_at(4i)"=>"17",
                "finish_at(5i)"=>"",
                "meeting_date"=>"2021-10-01",
                "room_entry_users"=>["0", "1"]
            }}
        }
        let(:invalid_date_params){
            {"meeting_room"=>{
                "name"=>"",
                "start_at(4i)"=>"10",
                "start_at(5i)"=>"00",
                "finish_at(4i)"=>"17",
                "finish_at(5i)"=>"00",
                "meeting_date"=>"",
                "room_entry_users"=>["0", "1"]
            }}
        }
        let(:invalid_entries_params){
            {"meeting_room"=>{
                "name"=>"",
                "start_at(4i)"=>"10",
                "start_at(5i)"=>"00",
                "finish_at(4i)"=>"17",
                "finish_at(5i)"=>"00",
                "meeting_date"=>"2021-10-01"
            }}
        }
        # ログイン済みユーザー
        context "user is logged in" do
            before do
                sign_in user
            end

            context "Request" do
                # 有効なパラメータ
                it "Success valid params" do
                    post meeting_rooms_path, params: meeting_room_params
                    expect(response.status).to eq 302
                    expect(response).to redirect_to meeting_rooms_path
                end

                # 無効なパラメータ(name)
                it "Error invalid name" do
                    post meeting_rooms_path, params: invalid_name_params
                    expect(response.status).to eq 200
                    expect(response).not_to redirect_to meeting_rooms_path
                end

                # 無効なパラメータ(start(4i))
                it "Error invalid start_hours" do
                    post meeting_rooms_path, params: invalid_start_params
                    expect(response.status).to eq 200
                    expect(response).not_to redirect_to meeting_rooms_path
                end

                # 無効なパラメータ(end(5i))
                it "Error invalid end_minutes" do
                    post meeting_rooms_path, params: invalid_end_params
                    expect(response.status).to eq 200
                    expect(response).not_to redirect_to meeting_rooms_path
                end

                # 無効なパラメータ(date)
                it "Error invalid date" do
                    post meeting_rooms_path, params: invalid_date_params
                    expect(response.status).to eq 200
                    expect(response).not_to redirect_to meeting_rooms_path
                end

                # 無効なパラメータ(entries)
                it "Error invalid entries" do
                    post meeting_rooms_path, params: invalid_entries_params
                    expect(response.status).to eq 200
                    expect(response).not_to redirect_to meeting_rooms_path
                end
            end

            context "Create" do
                # 有効なパラメータ
                it "Success valid params" do
                    expect do
                        post meeting_rooms_path, params: meeting_room_params
                    end.to change { MeetingRoom.count }.by(1).and change { Entry.count }.by(3)
                end

                # 無効なパラメータ
                it "Error invalid params" do
                    expect do
                        post meeting_rooms_path, params: invalid_name_params
                    end.to change { MeetingRoom.count }.by(0).and change { Entry.count }.by(0)
                end
            end
        end
    end

end