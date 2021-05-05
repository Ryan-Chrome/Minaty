require 'rails_helper'

RSpec.describe "User", type: :request do

    let!(:user){ create(:user) }
    let!(:other_user){ create(:other_user) }
    let(:header){ { "HTTP_REFERER" => root_url } }
    let(:invalid_header){ { "HTTP_REFERER" => meeting_rooms_url } }

    # ユーザー検索結果表示
    describe "GET #index" do
        let(:valid_params){ {"department"=>"人事部", "name"=>"other_user"} }
        let(:invalid_params){ {"department"=>"", "name"=>""} }
        # ログイン済みユーザー
        context "user is logged in" do
            before do
                sign_in user
            end

            context "Request" do
                # root_pathからのリクエスト(JS形式)
                it "Success from root_path(JS)" do
                    get users_path, params: valid_params, headers: header, xhr: true
                    expect(response.status).to eq 200
                end

                # JS形式以外のリクエストは例外になること
                it "Error format html" do
                    expect do
                        get users_path, params: valid_params, headers: header
                    end.to raise_error { ActionController::RoutingError }
                end

                # root_path以外からのリクエスト
                it "Error from not root_path" do
                    get users_path, params: valid_params, headers: invalid_header, xhr: true
                    expect(response.status).to eq 302
                    expect(response).to redirect_to root_path
                end
            end

            context "Search response" do
                # 該当するユーザーがいた場合
                it "There is applicable user" do
                    get users_path, params: valid_params, headers: header, xhr: true
                    expect(response.body).to include("other_user")
                end

                # 該当するユーザーがいない場合
                it "There is not applicable user" do
                    get users_path, params: invalid_params, headers: header, xhr: true
                    expect(response.body).to include("存在しません")
                end
            end
        end
    end

    # ユーザー詳細表示
    describe "GET #show" do
        # ログイン済みユーザー
        context "user is logged in" do
            before do
                sign_in user
            end

            context "Request" do
                # root_pathからのリクエスト(JS形式)
                it "Success from root_path(JS)" do
                    get user_path(other_user.public_uid), headers: header, xhr: true
                    expect(response.status).to eq 200
                end

                # JS形式以外のリクエストは例外になること
                it "Error format html" do
                    expect do
                        get user_path(other_user.public_uid), headers: header
                    end.to raise_error { ActionController::RoutingError }
                end

                # root_path以外からのリクエスト
                it "Error from not root_path" do
                    get user_path(other_user.public_uid), headers: invalid_header, xhr: true
                    expect(response.status).to eq 302
                    expect(response).to redirect_to root_path
                end
            end

            context "User show response" do
                # 存在するユーザーのIDだった場合
                it "There is applicable user" do
                    get user_path(other_user.public_uid), headers: header, xhr: true
                    expect(response.body).to include("ユーザー詳細")
                end

                # 存在しないユーザーのIDだった場合
                it "There is not applicable user" do
                    get user_path("fsda"), headers: header, xhr: true
                    expect(response.body).not_to include("ユーザー詳細")
                end
            end
        end
    end

end