require 'rails_helper'

RSpec.describe "GeneralMessage", type: :request do

    let!(:user){ create(:user) }
    let!(:other_user){ create(:other_user) }
    let!(:therd_user){ create(:therd_user) }
    let(:header){ { "HTTP_REFERER" => root_url } }
    let(:invalid_header){ { "HTTP_REFERER" =>  meeting_rooms_url} }

    # メッセージの送信先一覧表示
    describe "GET #show" do
        let!(:message){ user.general_messages.create(content: "テストテキスト") }
        let!(:message_relation){ message.general_message_relations.create(user_id: user.id, receive_user_id: other_user.id) }
        # ログイン済みユーザー
        context "user is logged in" do
            before do
                sign_in user
            end

            context "Request" do
                # root_pathからのリクエスト(js形式)成功
                it "Success from root_path(js)" do
                    get general_message_path(message.id), headers: header, xhr: true
                    expect(response.status).to eq 200
                    expect(response).not_to redirect_to root_path
                end

                # js形式以外のリクエストは例外になること
                it "Error from root_path(html)" do
                    expect do
                        get general_message_path(message.id), headers: header
                    end.to raise_error(ActionController::RoutingError)
                end

                # root_path以外からのリクエスト(アプリ内)をroot_pathへリダイレクト
                it "Recirect not from root_path" do
                    get general_message_path(message.id), headers: invalid_header, xhr: true
                    expect(response.status).to eq 302
                    expect(response).to redirect_to root_path
                end
            end
        end

        # 未ログインユーザー
        context "user is not logged in" do
            context "Request" do
                # 認証失敗すること
                it "Authentication error" do
                    get general_message_path(message.id), headers: header, xhr: true
                    expect(response.status).to eq 401
                end
            end
        end
    end

    # メッセージ新規作成
    describe "POST #create" do
        let(:message_params){ {"general_message"=>{"content"=>"テストテキスト", "receive_user_id"=>"#{other_user.public_uid}"}} }
        let(:invalid_message_params_a){ {"general_message"=>{"content"=>"", "receive_user_id"=>"#{other_user.public_uid}"}} }
        let(:invalid_message_params_b){ {"general_message"=>{"content"=>"テストテキスト", "receive_user_id"=>""}} }
        # ログイン済みユーザー
        context "user is logged in" do
            before do
                sign_in user
            end

            context "Request" do
                # root_pathからのリクエスト(js形式)成功
                it "Success from root_path(js)" do
                    post general_messages_path, params: message_params, headers: header, xhr: true
                    expect(response.status).to eq 200
                    expect(response).not_to redirect_to root_path
                end

                # js形式以外のリクエストは例外になること
                it "Error from root_path(html)" do
                    expect do
                        post general_messages_path, params: message_params, headers: header
                    end.to raise_error(ActionController::RoutingError)
                end

                # root_path以外からのリクエスト(アプリ内)をroot_pathへリダイレクト
                it "Recirect not from root_path" do
                    post general_messages_path, params: message_params, headers: invalid_header, xhr: true
                    expect(response.status).to eq 200
                    expect(response).to redirect_to root_path
                end
            end

            context "Create" do
                # 有効なパラメータかつ有効なアプリ内ページ(root_path: 成功)
                # general_message_relationも作成されること
                it "Success valid params and valid header" do
                    expect do
                        post general_messages_path, params: message_params, headers: header, xhr: true
                    end.to change{ GeneralMessage.count }.by(1).and change{ GeneralMessageRelation.count }.by(1)
                end

                # 無効なパラメータ(contentが空の場合: 失敗)
                it "Error invalid params(not content)" do
                    expect do
                        post general_messages_path, params: invalid_message_params_a, headers: header, xhr: true
                    end.to change{ GeneralMessage.count }.by(0).and change{ GeneralMessageRelation.count }.by(0)
                end

                # 無効なパラメータ(receive_user_idが空の場合: 失敗)
                it "Error invalid params(not receive_user_id)" do
                    expect do
                        post general_messages_path, params: invalid_message_params_b, headers: header, xhr: true
                    end.to change{ GeneralMessage.count }.by(0).and change{ GeneralMessageRelation.count }.by(0)
                end

                # 無効なアプリ内ページ(失敗)
                it "Error invalid header" do
                    expect do
                        post general_messages_path, params: message_params, headers: invalid_header, xhr: true
                    end.to change{ GeneralMessage.count }.by(0).and change{ GeneralMessageRelation.count }.by(0)
                end
            end

            context "Display message" do
                # メッセージの作成に成功し場合
                it "Success create" do
                    post general_messages_path, params: message_params, headers: header, xhr: true
                    expect(response.body).to include("テストテキスト")
                end

                # メッセージの作成に失敗した場合
                it "Error create" do
                    post general_messages_path, params: invalid_message_params_a, headers: header, xhr: true
                    expect(response.body).not_to include("テストテキスト")
                end
            end
        end
    end

    # 複数人宛にメッセージを新規作成
    describe "POST #multiple_create" do
        let!(:meeting_room){ create(:meeting_room) }
        let!(:entry){ meeting_room.entries.create(user_id: user.id) }
        let(:message_params){ {"general_message"=>{"content"=>"テストテキスト"}, "general_message_send_users"=>["#{other_user.public_uid}", "#{therd_user.public_uid}"]} }
        let(:invalid_message_params_a){ {"general_message"=>{"content"=>""}, "general_message_send_users"=>["#{other_user.public_uid}", "#{therd_user.public_uid}"]} }
        let(:invalid_message_params_b){ {"general_message"=>{"content"=>"テストテキスト"} } }
        let(:meeting_room_header){ { "HTTP_REFERER" => meeting_room_url(meeting_room.public_uid) } }
        # ログイン済みユーザー
        context "user is logged in" do
            before do
                sign_in user
            end

            context "Request" do
                # root_pathからのリクエスト(js形式)成功
                it "Success from root_path(js)" do
                    post general_messages_multiple_create_path, params: message_params, headers: header, xhr: true
                    expect(response.status).to eq 200
                    expect(response).not_to redirect_to root_path
                end

                # 自分の持つミーティングルームからのリクエスト(js形式)成功
                it "Success from my_meeting_room_path(js)" do
                    post general_messages_multiple_create_path, params: message_params, headers: meeting_room_header, xhr: true
                    expect(response.status).to eq 200
                    expect(response).not_to redirect_to root_path
                end

                # js形式以外のリクエストは例外になること
                it "Error from root_path(html)" do
                    expect do
                        post general_messages_multiple_create_path, params: message_params, headers: header
                    end.to raise_error(ActionController::RoutingError)
                end

                # root_path&自分の持つミーティングルーム以外からのリクエスト(アプリ内)をroot_pathへリダイレクト
                it "Redirect not from root_path & my_meeting_room_path" do
                    post general_messages_multiple_create_path, params: message_params, headers: invalid_header, xhr: true
                    expect(response.status).to eq 200
                    expect(response).to redirect_to root_path
                end
            end

            context "Create" do
                # 有効なパラメータかつ有効なアプリ内ページ(root_path: 成功)
                it "Success valid params and valid header" do
                    expect do
                        post general_messages_multiple_create_path, params: message_params, headers: header, xhr: true
                    end.to change{ GeneralMessage.count }.by(1).and change{ GeneralMessageRelation.count }.by(2)
                end

                # 有効なパラメータかつ有効なアプリ内ページ(meeting_room_path: 成功)
                it "Success valid params and valid meeting_room_header" do
                    expect do
                        post general_messages_multiple_create_path, params: message_params, headers: meeting_room_header, xhr: true
                    end.to change{ GeneralMessage.count }.by(1).and change{ GeneralMessageRelation.count }.by(2)
                end

                # 無効なアプリ内ページ(失敗)
                it "Error invalid header" do
                    expect do 
                        post general_messages_multiple_create_path, params: message_params, headers: invalid_header, xhr: true
                    end.to change{ GeneralMessage.count }.by(0).and change{ GeneralMessageRelation.count }.by(0)
                end

                # 無効なパラメータ(内容が空の場合: 失敗)
                it "Error invalid params(invalid content)" do
                    expect do
                        post general_messages_multiple_create_path, params: invalid_message_params_a, headers: header, xhr: true
                    end.to change{ GeneralMessage.count }.by(0).and change{ GeneralMessageRelation.count }.by(0)
                end

                # 無効なパラメータ(送信先ユーザーが空の場合: 失敗)
                it "Error invalid params(invalid user_id)" do
                    expect do
                        post general_messages_multiple_create_path, params: invalid_message_params_b, headers: header, xhr: true
                    end.to change{ GeneralMessage.count }.by(0).and change{ GeneralMessageRelation.count }.by(0)
                end
            end

            context "Display message" do
                # メッセージの作成に成功し場合
                it "Success create" do
                    post general_messages_multiple_create_path, params: message_params, headers: header, xhr: true
                    expect(response.body).to include("テストテキスト")
                end

                # メッセージの作成に失敗した場合
                it "Error create" do
                    post general_messages_multiple_create_path, params: invalid_message_params_a, headers: header, xhr: true
                    expect(response.body).not_to include("テストテキスト")
                end
            end
        end
    end

    # ユーザー詳細ページのチャットコンテンツ読み込み(スクロール時)
    describe "GET #message_ajax" do
        # ログイン済みユーザー
        context "user is logged in" do
            before do
                sign_in user
            end

            context "Request" do
                # root_pathからのリクエスト成功
                it "Success from root_path" do
                    get general_messages_other_user_chat_ajax_path, params: { "other_user"=>"#{other_user.public_uid}", "page"=>"2" }, headers: header
                    expect(response.status).to eq 200
                    expect(response).not_to redirect_to root_path
                end

                # root_path以外からのリクエストはroot_pathへリダイレクト
                it "Error from not root_path" do
                    get general_messages_other_user_chat_ajax_path, params: { "other_user"=>"#{other_user.public_uid}", "page"=>"2" }, headers: invalid_header
                    expect(response.status).to eq 302
                    expect(response).to redirect_to root_path
                end
            end
        end
    end

    # ホームチャットコンテンツの読み込み(スクロール時)
    describe "GET #home_message_ajax" do
        # ログイン済みユーザー
        context "user is logged in" do
            before do
                sign_in user
            end

            context "Request" do
                # root_pathからのリクエスト成功
                it "Success from root_path" do
                    get general_messages_home_chat_ajax_path, params: { "page"=>"2" }, headers: header
                    expect(response.status).to eq 200
                    expect(response).not_to redirect_to root_path
                end

                # root_path以外からのリクエストはroot_pathへリダイレクト
                it "Error from not root_path" do
                    get general_messages_home_chat_ajax_path, params: { "page"=>"2" }, headers: invalid_header
                    expect(response.status).to eq 302
                    expect(response).to redirect_to root_path
                end
            end
        end
    end

end