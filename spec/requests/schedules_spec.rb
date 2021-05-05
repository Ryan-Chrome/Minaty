require 'rails_helper'

# Scheduleにおける全てのアクションはJSフォーマット以外は受け付けない
RSpec.describe "Schedule", type: :request do

    let!(:user){ create(:user) }
    let(:header){ { "HTTP_REFERER" => root_url } }
    let(:invalid_header){ { "HTTP_REFERER" =>  meeting_rooms_url} }

    # スケジュール追加日付送信後の新規作成フォーム表示
    describe "GET #new" do
        # ログイン済みユーザー
        context "user is logged in" do
            before do
                sign_in user
            end

            context "Request" do
                # root_pathからのリクエスト(js形式)成功
                it "Success from root_path(js)" do
                    get new_schedule_path, params: { add_date: Date.today }, headers: header, xhr: true
                    expect(response.status).to eq 200
                    expect(response.body).to match("modal.insertAdjacentHTML")
                    expect(response).not_to redirect_to root_path
                end

                # js形式以外のリクエストは例外になること
                it "Error from root_path(html)" do
                    expect do
                        get new_schedule_path, params: { add_date: Date.today }, headers: header
                    end.to raise_error(ActionController::RoutingError)
                end

                # root_path以外からのリクエスト(アプリ内)をroot_pathへリダイレクト
                it "Redirect not from root_path" do
                    get new_schedule_path, params: { add_date: Date.today }, headers: invalid_header, xhr: true
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
                    get new_schedule_path, params: { add_date: Date.today }, headers: header, xhr: true
                    expect(response.status).to eq 401
                end
            end
        end
    end

    # ミーティング通知から新規作成フォーム表示
    describe "GET #meeting_new" do
        let!(:meeting_room){ create(:meeting_room) }
        let!(:entry){ meeting_room.entries.create(user_id: user.id) }
        # ログイン済みユーザー
        context "user is logged in" do
            before do
                sign_in user
            end

            context "Request" do
                # root_pathからのリクエスト(js形式)成功
                it "Success from root_path(js)" do
                    get schedules_meeting_new_path, params: { meeting_room_id: meeting_room.public_uid }, headers: header, xhr: true
                    expect(response.status).to eq 200
                    expect(response.body).to match("modal.insertAdjacentHTML")
                end

                # js形式以外のリクエストは例外になること
                it "Error from root_path(html)" do
                    expect do
                        get schedules_meeting_new_path, params: { meeting_room_id: meeting_room.public_uid }, headers: header
                    end.to raise_error(ActionController::RoutingError)
                end

                # root_path以外からのリクエスト(アプリ内)をroot_pathへリダイレクト
                it "Redirect not from root_path" do
                    get schedules_meeting_new_path, params: { meeting_room_id: meeting_room.public_uid }, headers: invalid_header, xhr: true
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
                    get schedules_meeting_new_path, params: { meeting_room_id: meeting_room.public_uid }, headers: header, xhr: true
                    expect(response.status).to eq 401
                end
            end
        end
    end

    # タイマーから新規作成フォーム表示
    describe "GET #add_timer" do
        let!(:meeting_room){ create(:meeting_room) }
        let!(:entry){ meeting_room.entries.create(user_id: user.id) }
        let(:time_params){ { start_time: "06:36", end_time: "12:45" } }
        let(:invalid_time_params){ { start_time: "timer", end_time: "timer" } }
        let(:meeting_room_header){ { "HTTP_REFERER" => meeting_room_url(meeting_room.public_uid) } }

        # ログイン済みユーザー
        context "user is logged in" do
            before do
                sign_in user
            end

            context "Request" do
                # root_pathからのリクエスト(js形式)成功
                it "Success from root_path(js)" do
                    get schedules_add_timer_path, params: time_params, headers: header, xhr: true
                    expect(response.status).to eq 200
                    expect(response.body).to match("add_schedule_next_back")
                end

                # 自分の持つミーティングルームからのリクエスト(js形式)成功
                it "Success from my_meeting_room_path(js)" do
                    get schedules_add_timer_path, params: time_params, headers: meeting_room_header, xhr: true
                    expect(response.status).to eq 200
                    expect(response.body).not_to match("add_schedule_next_back")
                    expect(response.body).to match("modal.insertAdjacentHTML")
                end

                # js形式以外のリクエストは例外になること
                it "Error from root_path(html)" do
                    expect do
                        get schedules_add_timer_path, params: time_params, headers: header
                    end.to raise_error(ActionController::RoutingError)
                end

                # root_path＆自分の持つミーティングルーム以外からのリクエスト(アプリ内)をroot_pathへリダイレクト
                it "Redirect not from root_path & my_meeting_room_path" do
                    get schedules_add_timer_path, params: time_params, headers: invalid_header, xhr: true
                    expect(response.status).to eq 302
                    expect(response).to redirect_to root_path
                end

                # パラメーターが不正な値
                it "Error invalid parameter value" do
                    get schedules_add_timer_path, params: invalid_time_params, headers: header, xhr: true
                    expect(response.status).to eq 200
                    expect(response.body).to eq ""
                end
            end
        end

        # 未ログインユーザー
        context "user is not logged in" do
            context "Request" do
                # 認証失敗すること
                it "Authentication error" do
                    get schedules_add_timer_path, params: time_params, headers: header, xhr: true
                    expect(response.status).to eq 401
                end
            end
        end
    end

    # 編集するスケジュール選択後の編集フォーム表示
    describe "GET #edit" do
        let!(:schedule){ create(:schedule, user_id: user.id) }
        # ログイン済みユーザー
        context "user is logged in" do
            before do
                sign_in user
            end

            context "Request" do
                # root_pathからのリクエスト(js形式)成功
                it "Success from root_path(js)" do
                    get edit_schedule_path(schedule.id), headers: header, xhr: true
                    expect(response.status).to eq 200
                    expect(response.body).to match("modal.insertAdjacentHTML")
                    expect(response).not_to redirect_to root_path
                end

                # js形式以外のリクエストは例外になること
                it "Error from root_path(html)" do
                    expect do
                        get edit_schedule_path(schedule.id), headers: header
                    end.to raise_error(ActionController::RoutingError)
                end

                # root_path以外からのリクエスト(アプリ内)をroot_pathへリダイレクト
                it "Redirect not from root_path" do
                    get edit_schedule_path(schedule.id), headers: invalid_header, xhr: true
                    expect(response.status).to eq 302
                    expect(response).to redirect_to root_path
                end
            end
        end

        # 未ログインユーザー
        context "user is not logged in" do
            # 認証失敗
            it "Authentication error" do
                get edit_schedule_path(schedule.id), headers: header, xhr: true
                expect(response.status).to eq 401
            end
        end
    end

    # スケジュール新規作成
    describe "POST #create" do
        let!(:meeting_room){ create(:meeting_room) }
        let!(:entry){ meeting_room.entries.create(user_id: user.id) }
        let(:schedule_params){ { "schedule"=>{"work_on"=>"#{Date.today}", "name"=>"会議", "start_at(4i)"=>"03", "start_at(5i)"=>"00", "finish_at(4i)"=>"07", "finish_at(5i)"=>"00"} } }
        let(:invalid_schedule_params){ { "schedule"=>{"work_on"=>"#{Date.today - 1}", "name"=>"会議", "start_at(4i)"=>"03", "start_at(5i)"=>"00", "finish_at(4i)"=>"07", "finish_at(5i)"=>"00"} } }
        let(:meeting_room_header){ { "HTTP_REFERER" => meeting_room_url(meeting_room.public_uid) } }
        # ログイン済みユーザー
        context "user is logged in" do
            before do
                sign_in user
            end

            context "Request" do
                # root_pathからのリクエスト(js形式)成功
                it "Success from root_path(js)" do
                    post schedules_path, params: schedule_params, headers: header, xhr: true
                    expect(response.status).to eq 200
                    expect(response).not_to redirect_to root_path
                end

                # 自分の持つミーティングルームからのリクエスト(js形式)成功
                it "Success from my_meeting_room_path(js)" do
                    post schedules_path, params: schedule_params, headers: meeting_room_header, xhr: true
                    expect(response.status).to eq 200
                    expect(response).not_to redirect_to root_path
                end

                # js形式以外のリクエストは例外になること
                it "Error from root_path(html)" do
                    expect do
                        post schedules_path, params: schedule_params, headers: header
                    end.to raise_error(ActionController::RoutingError)
                end

                # root_path＆自分の持つミーティングルーム以外からのリクエスト(アプリ内)をroot_pathへリダイレクト
                it "Redirect not from root_path & my_meeting_room_path" do
                    post schedules_path, params: schedule_params, headers: invalid_header, xhr: true
                    expect(response.status).to eq 200
                    expect(response).to redirect_to root_path
                end
            end

            context "Create" do
                # 有効なパラメータかつ有効なアプリ内ページ(root_path: 成功)
                it "Success valid params and valid header" do
                    expect do
                        post schedules_path, params: schedule_params, headers: header, xhr: true
                    end.to change{ Schedule.count }.by(1)
                end

                # 有効なパラメータかつ有効なアプリ内ページ(my_meeting_path: 成功)
                it "Success valid params and valid meeting_room_header" do
                    expect do
                        post schedules_path, params: schedule_params, headers: meeting_room_header, xhr: true
                    end.to change{ Schedule.count }.by(1)
                end

                # 無効なアプリ内ページ(失敗)
                it "Error invalud header" do
                    expect do
                        post schedules_path, params: schedule_params, headers: invalid_header, xhr: true
                    end.to change{ Schedule.count }.by(0)
                end

                # 無効なパラメータ(失敗)
                it "Error invalud params" do
                    expect do
                        post schedules_path, params: invalid_schedule_params, headers: header, xhr: true
                    end.to change{ Schedule.count }.by(0)
                end
            end

            context "Message" do
                # 成功メッセージが表示されること
                it "Success message" do
                    post schedules_path, params: schedule_params, headers: header, xhr: true
                    expect(response.body).to match("スケジュールを追加しました。")
                end

                # エラーメッセージが表示されること
                it "Error message" do
                    post schedules_path, params: invalid_schedule_params, headers: header, xhr: true
                    expect(response.body).to match("処理に失敗しました。")
                end
            end
        end

        # 未ログインユーザー
        context "user is not logged in" do
            context "Request" do
                # 認証失敗
                it "Error root_path" do
                    post schedules_path, params: schedule_params, headers: header, xhr: true
                    expect(response.status).to eq 401
                end
            end
        end
    end

    # スケジュール編集
    describe "PATCH #update" do
        let!(:schedule){ create(:schedule, user_id: user.id) }
        let!(:other_user){ create(:other_user) }
        let!(:other_user_schedule){ create(:schedule, user_id: other_user.id) }
        let(:schedule_params){ { "schedule"=>{"name"=>"会議", "edit_start_at(4i)"=>"03", "edit_start_at(5i)"=>"00", "edit_finish_at(4i)"=>"07", "edit_finish_at(5i)"=>"00"} } }
        let(:invalid_schedule_params){ { "schedule"=>{"name"=>"会議", "edit_start_at(4i)"=>"12", "edit_start_at(5i)"=>"00", "edit_finish_at(4i)"=>"07", "edit_finish_at(5i)"=>"00"} } }
        # ログイン済みユーザー
        context "user is logged in" do
            before do
                sign_in user
            end

            context "Request" do
                # root_pathからのリクエスト(js形式)成功
                it "Success from root_path" do
                    patch schedule_path(schedule.id), params: schedule_params, headers: header, xhr: true
                    expect(response.status).to eq 200
                    expect(response).not_to redirect_to root_path
                end

                # js形式以外のリクエストは例外になること
                it "Error from root_path(html)" do
                    expect do
                        patch schedule_path(schedule.id), params: schedule_params, headers: header
                    end.to raise_error(ActionController::RoutingError)
                end

                # root_path以外からのリクエスト(アプリ内)をroot_pathへリダイレクト
                it "Redirect not from root_path" do
                    patch schedule_path(schedule.id), params: schedule_params, headers: invalid_header, xhr: true
                    expect(response.status).to eq 200
                    expect(response).to redirect_to root_path
                end
            end

            context "Update" do
                # 有効なパラメータかつ有効なアプリ内ページ(root_path: 成功)
                it "Success valid params and valid header" do
                    patch schedule_path(schedule.id), params: schedule_params, headers: header, xhr: true
                    expect(schedule.reload.name).to eq "会議"
                end

                # 無効なパラメータ(失敗)
                it "Error invalid params" do
                    patch schedule_path(schedule.id), params: invalid_schedule_params, headers: header, xhr: true
                    expect(schedule.reload.name).not_to eq "会議"
                end

                # 自分のスケジュールではない場合(失敗)
                it "Error other_user_schedule" do
                    patch schedule_path(other_user_schedule.id), params: schedule_params, headers: header, xhr: true
                    expect(schedule.reload.name).not_to eq "会議"
                end

                # 無効なアプリ内ページ(失敗)
                it "Error invalid header" do
                    patch schedule_path(schedule.id), params: schedule_params, headers: invalid_header, xhr: true
                    expect(schedule.reload.name).not_to eq "会議"
                end
            end

            context "Message" do
                # 成功メッセージ表示されること
                it "Success message" do
                    patch schedule_path(schedule.id), params: schedule_params, headers: header, xhr: true
                    expect(response.body).to match("スケジュールを編集しました。")
                end

                # エラーメッセージが表示されること
                it "Error message" do
                    patch schedule_path(schedule.id), params: invalid_schedule_params, headers: header, xhr: true
                    expect(response.body).to match("編集に失敗しました。")
                end
            end
        end
    end

    # スケジュール削除
    describe "DELETE #destroy" do
        let!(:schedule){ create(:schedule, user_id: user.id) }
        let!(:other_user){ create(:other_user) }
        let!(:other_user_schedule){ create(:schedule, user_id: other_user.id) }
        # ログイン済みユーザー
        context "user is logged in" do
            before do
                sign_in user
            end

            context "Request" do
                # root_pathからのリクエスト(js形式)成功
                it "Success from root_path(js)" do
                    delete schedule_path(schedule.id), headers: header, xhr: true
                    expect(response.status).to eq 200
                    expect(response).not_to redirect_to root_path
                end

                # js形式以外のリクエストは例外になること
                it "Error from root_path(html)" do
                    expect do
                        delete schedule_path(schedule.id), headers: header
                    end.to raise_error(ActionController::RoutingError)
                end

                # root_path以外からのリクエスト(アプリ内)をroot_pathへリダイレクト
                it "Redirect not from root_path" do
                    delete schedule_path(schedule.id), headers: invalid_header, xhr: true
                    expect(response.status).to eq 200
                    expect(response).to redirect_to root_path
                end
            end

            context "Destroy" do
                # 存在する自分のスケジュールかつ有効なアプリ内ページ(root_path: 成功)
                it "Success valid schedule and valid header" do
                    expect do
                        delete schedule_path(schedule.id), headers: header, xhr: true
                    end.to change{ Schedule.count }.by(-1)
                end

                # 無効なアプリ内ページ(失敗)
                it "Error invalid header" do
                    expect do
                        delete schedule_path(schedule.id), headers: invalid_header, xhr: true
                    end.to change{ Schedule.count }.by(0)
                end

                # 自分のスケジュールではない場合(失敗)
                it "Error other_user_schedule" do
                    expect do
                        delete schedule_path(other_user_schedule.id), headers: header, xhr: true
                    end.to change{ Schedule.count }.by(0)
                end
            end

            context "Message" do
                # 成功メッセージが表示されること
                it "Success message" do
                    delete schedule_path(schedule.id), headers: header, xhr: true
                    expect(response.body).to match("スケジュールを削除しました。")
                end

                # エラーメッセージが表示されること
                it "Error message" do
                    delete schedule_path(other_user_schedule.id), headers: header, xhr: true
                    expect(response.body).to match("削除に失敗しました。")
                end
            end
        end
    end

end