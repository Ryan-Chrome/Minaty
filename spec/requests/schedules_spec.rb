require "rails_helper"

RSpec.describe "Schedule", type: :request do
  let!(:dept) { create(:human_resources_dept) }
  let!(:user) { create(:user, department_id: dept.id) }
  let(:valid_header) { { "HTTP_REFERER" => root_url } }
  let(:invalid_header) { { "HTTP_REFERER" => meeting_rooms_url } }

  # スケジュール追加日付送信後の新規作成フォーム表示
  describe "GET #new" do
    context "ログイン済" do
      before { sign_in user }
      
      context "root_pathからAjax通信かつフォーマットがJS形式の場合" do
        context "パラメータが正の場合" do
          subject {
            get new_schedule_path,
                params: { add_date: Date.today },
                headers: valid_header,
                xhr: true
          }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "スケジュール新規作成フォーム表示" do
            subject
            expect(response.body).to include "add-schedule-next-main"
          end
        end

        context "パラメータが不正な場合" do
          subject {
            get new_schedule_path,
                params: { add_date: "" },
                headers: valid_header,
                xhr: true
          }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "スケジュール新規作成フォーム表示されないこと" do
            subject
            expect(response.body).not_to include "add-schedule-next-main"
          end
        end
      end

      context "フォーマットがJS形式以外の場合" do
        it "ルーティングエラー" do
          expect do
            get new_schedule_path(format: :html),
                params: { add_date: Date.today },
                headers: valid_header,
                xhr: true
          end.to raise_error(ActionController::RoutingError)
        end
      end

      context "Ajax通信でない場合" do
        it "ルーティングエラー" do
          expect do
            get new_schedule_path(format: :js),
                params: { add_date: Date.today },
                headers: valid_header
          end.to raise_error(ActionController::RoutingError)
        end
      end

      context "root_path以外からの場合" do
        subject {
          get new_schedule_path,
              params: { add_date: Date.today },
              headers: invalid_header,
              xhr: true
        }

        it "リクエスト成功" do
          subject
          expect(response.status).to eq 302
        end

        it "root_pathへリダイレクト" do
          subject
          expect(response).to redirect_to root_path
        end
      end
    end

    context "未ログイン" do
      it "認証失敗エラーコードが返ってくること" do
        get new_schedule_path,
            params: { add_date: Date.today },
            headers: valid_header,
            xhr: true
        expect(response.status).to eq 401
      end
    end
  end

  # ミーティング通知から新規作成フォーム表示
  describe "GET #meeting_new" do
    let!(:meeting_room) { create(:meeting_room) }
    let!(:entry) { meeting_room.users << user }
    let!(:other_meeting_room) { create(:meeting_room) }
    
    context "ログイン済" do
      before { sign_in user }

      context "root_pathからAjax通信かつフォーマットがJS形式の場合" do
        context "パラメータが正の場合" do
          subject {
            get schedules_meeting_new_path,
                params: { meeting_room_id: meeting_room.public_uid },
                headers: valid_header,
                xhr: true
          }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "スケジュール新規作成フォーム表示" do
            subject
            expect(response.body).to include "add-schedule-next-main"
          end
        end

        context "パラメータが不正な場合" do
          subject {
            get schedules_meeting_new_path,
                params: { meeting_room_id: other_meeting_room.public_uid },
                headers: valid_header,
                xhr: true
          }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "スケジュール新規作成フォーム表示されないこと" do
            subject
            expect(response.body).not_to include "add-schedule-next-main"
          end
        end
      end

      context "フォーマットがJS形式以外の場合" do
        it "ルーティングエラー" do
          expect do
            get schedules_meeting_new_path(format: :html),
                params: { meeting_room_id: meeting_room.public_uid },
                headers: valid_header,
                xhr: true
          end.to raise_error(ActionController::RoutingError)
        end
      end

      context "Ajax通信でない場合" do
        it "ルーティングエラー" do
          expect do
            get schedules_meeting_new_path(format: :js),
                params: { meeting_room_id: meeting_room.public_uid },
                headers: valid_header
          end.to raise_error(ActionController::RoutingError)
        end
      end

      context "root_path以外からの場合" do
        subject {
          get schedules_meeting_new_path,
              params: { meeting_room_id: meeting_room.public_uid },
              headers: invalid_header,
              xhr: true
        }

        it "リクエスト成功" do
          subject
          expect(response.status).to eq 302
        end

        it "root_pathへリダイレクト" do
          subject
          expect(response).to redirect_to root_path
        end
      end
    end

    context "未ログイン" do
      it "認証失敗エラーコードが返ってくること" do
        get schedules_meeting_new_path,
            params: { meeting_room_id: meeting_room.public_uid },
            headers: valid_header,
            xhr: true
        expect(response.status).to eq 401
      end
    end
  end

  # タイマーから新規作成フォーム表示
  describe "GET #add_timer" do
    let!(:meeting_room) { create(:meeting_room) }
    let!(:entry) { meeting_room.entries.create(user_id: user.id) }
    let(:valid_params) { { start_time: "06:36", end_time: "12:45" } }
    let(:invalid_params) { { start_time: "timer", end_time: "timer" } }
    let(:meeting_room_header) { { "HTTP_REFERER" => meeting_room_url(meeting_room.public_uid) } }

    context "ログイン済" do
      before { sign_in user }
      
      context "root_pathからAjax通信かつフォーマットがJS形式の場合" do
        context "パラメータが正の場合" do
          subject {
            get schedules_add_timer_path,
                params: valid_params,
                headers: valid_header,
                xhr: true
          }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "スケジュール新規作成フォーム表示" do
            subject
            expect(response.body).to include "add-schedule-next-main"
          end
        end

        context "パラメータが不正な場合" do
          subject {
            get schedules_add_timer_path,
                params: invalid_params,
                headers: valid_header,
                xhr: true
          }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "スケジュール新規作成フォーム表示されないこと" do
            subject
            expect(response.body).not_to include "add-schedule-next-main"
          end
        end
      end

      context "エントリーしているルームからAjax通信かつフォーマットがJS形式の場合" do
        context "パラメータが正の場合" do
          subject {
            get schedules_add_timer_path,
                params: valid_params,
                headers: meeting_room_header,
                xhr: true
          }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "スケジュール新規作成フォーム表示" do
            subject
            expect(response.body).to include "add-schedule-next-main"
          end
        end

        context "パラメータが不正な場合" do
          subject {
            get schedules_add_timer_path,
                params: invalid_params,
                headers: meeting_room_header,
                xhr: true
          }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "スケジュール新規作成フォーム表示されないこと" do
            subject
            expect(response.body).not_to include "add-schedule-next-main"
          end
        end
      end

      context "フォーマットがJS形式以外の場合" do
        it "ルーティングエラー" do
          expect do
            get schedules_add_timer_path(format: :html),
                params: valid_params,
                headers: meeting_room_header,
                xhr: true
          end.to raise_error(ActionController::RoutingError)
        end
      end

      context "Ajax通信でない場合" do
        it "ルーティングエラー" do
          expect do
            get schedules_add_timer_path(format: :js),
                params: valid_params,
                headers: meeting_room_header
          end.to raise_error(ActionController::RoutingError)
        end
      end

      context "root_path、エントリーしているルーム以外からの場合" do
        subject {
          get schedules_add_timer_path,
              params: valid_params,
              headers: invalid_header,
              xhr: true
        }

        it "リクエスト成功" do
          subject
          expect(response.status).to eq 302
        end

        it "root_pathへリダイレクト" do
          subject
          expect(response).to redirect_to root_path
        end
      end
    end

    context "未ログイン" do
      it "認証失敗エラーコードが返ってくること" do
        get schedules_add_timer_path,
            params: valid_params,
            headers: meeting_room_header,
            xhr: true
        expect(response.status).to eq 401
      end
    end
  end

  # スケジュール新規作成
  describe "POST #create" do
    let!(:meeting_room) { create(:meeting_room) }
    let!(:entry) { meeting_room.entries.create(user_id: user.id) }
    let(:valid_params) { 
      { "schedule" => { 
        "work_on" => "#{Date.today}",
        "name" => "会議",
        "start_at(4i)" => "03",
        "start_at(5i)" => "00",
        "finish_at(4i)" => "07",
        "finish_at(5i)" => "00" 
      } } 
    }
    let(:invalid_params) {
      { "schedule" => {
        "work_on" => "#{Date.today - 1}",
        "name" => "会議",
        "start_at(4i)" => "03",
        "start_at(5i)" => "00",
        "finish_at(4i)" => "07",
        "finish_at(5i)" => "00" 
      } } 
    }
    let(:meeting_room_header) { { "HTTP_REFERER" => meeting_room_url(meeting_room.public_uid) } }
    
    context "ログイン済" do
      before { sign_in user }

      context "root_pathからAjax通信かつフォーマットがJS形式の場合" do
        context "パラメータが正の場合" do
          subject {
            post schedules_path,
                 params: valid_params,
                 headers: valid_header,
                 xhr: true
          }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "スケジュール作成成功" do
            expect do
              subject
            end.to change { Schedule.count }.by(1)
          end

          it "作成成功メッセージ表示" do
            subject
            expect(response.body).to include "スケジュールを追加しました。"
          end
        end

        context "パラメータが不正な場合" do
          subject {
            post schedules_path,
                 params: invalid_params,
                 headers: valid_header,
                 xhr: true
          }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "スケジュール作成失敗" do
            expect do
              subject
            end.to change { Schedule.count }.by(0)
          end

          it "作成失敗メッセージ表示" do
            subject
            expect(response.body).to include "処理に失敗しました。"
          end
        end
      end

      context "エントリーしているルームからAjax通信かつフォーマットがJS形式の場合" do
        context "パラメータが正の場合" do
          subject {
            post schedules_path,
                 params: valid_params,
                 headers: meeting_room_header,
                 xhr: true
          }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "スケジュール作成成功" do
            expect do
              subject
            end.to change { Schedule.count }.by(1)
          end

          it "作成成功メッセージ表示" do
            subject
            expect(response.body).to include "スケジュールを追加しました。"
          end
        end

        context "パラメータが不正な場合" do
          subject {
            post schedules_path,
                 params: invalid_params,
                 headers: meeting_room_header,
                 xhr: true
          }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "スケジュール作成失敗" do
            expect do
              subject
            end.to change { Schedule.count }.by(0)
          end

          it "作成失敗メッセージ表示" do
            subject
            expect(response.body).to include "処理に失敗しました。"
          end
        end
      end

      context "フォーマットがJS形式以外の場合" do
        it "ルーティングエラー" do
          expect do
            post schedules_path(format: :html),
                 params: valid_params,
                 headers: valid_header,
                 xhr: true
          end.to raise_error(ActionController::RoutingError)
        end
      end

      context "Ajax通信でない場合" do
        it "ルーティングエラー" do
          expect do
            post schedules_path(format: :js),
                 params: valid_params,
                 headers: valid_header
          end.to raise_error(ActionController::RoutingError)
        end
      end

      context "root_path、エントリーしているルーム以外からの場合" do
        subject {
          post schedules_path,
               params: valid_params,
               headers: invalid_header,
               xhr: true
        }

        it "リクエスト成功" do
          subject
          expect(response.status).to eq 200
        end

        it "スケジュール作成失敗" do
          expect do
            subject
          end.to change { Schedule.count }.by(0)
        end

        it "root_pathへリダイレクト" do
          subject
          expect(response).to redirect_to root_path
        end
      end
    end

    context "未ログイン" do
      it "認証失敗エラーコードが返ってくること" do
        post schedules_path,
          params: valid_params,
          headers: valid_header,
          xhr: true
        expect(response.status).to eq 401
      end
    end
  end

  # 編集するスケジュール選択後の編集フォーム表示
  describe "GET #edit" do
    let!(:schedule) { create(:schedule, user_id: user.id) }
    let!(:other_user) { create(:other_user, department_id: dept.id) }
    let!(:other_schedule) { create(:schedule, user_id: other_user.id) }

    context "ログイン済" do
      before { sign_in user }

      context "root_pahtからAjax通信かつフォーマットがJS形式の場合" do
        context "パラメータが正の場合" do
          subject {
            get edit_schedule_path(schedule.id),
                headers: valid_header,
                xhr: true
          }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "スケジュール編集フォーム表示" do
            subject
            expect(response.body).to include "edit-schedule-next-main"
          end
        end

        context "パラメータが不正な場合" do
          subject {
            get edit_schedule_path(other_schedule.id),
                headers: valid_header,
                xhr: true
          }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "スケジュール編集フォーム表示されないこと" do
            subject
            expect(response.body).not_to include "edit-schedule-next-main"
          end
        end
      end

      context "フォーマットがJS形式以外の場合" do
        it "ルーティングエラー" do
          expect do
            get edit_schedule_path(schedule.id, format: :html),
                headers: valid_header,
                xhr: true
          end.to raise_error(ActionController::RoutingError)
        end
      end

      context "Ajax通信でない場合" do
        it "ルーティングエラー" do
          expect do
            get edit_schedule_path(schedule.id, format: :js),
                headers: valid_header
          end.to raise_error(ActionController::RoutingError)
        end
      end

      context "root_path以外からの場合" do
        subject {
          get edit_schedule_path(schedule.id),
              headers: invalid_header,
              xhr: true
        }

        it "リクエスト成功" do
          subject
          expect(response.status).to eq 302
        end

        it "root_pathへリダイレクト" do
          subject
          expect(response).to redirect_to root_path
        end
      end
    end

    context "未ログイン" do
      it "認証失敗エラーコードが返ってくること" do
        get edit_schedule_path(schedule.id),
            headers: valid_header,
            xhr: true
        expect(response.status).to eq 401
      end
    end
  end

  # スケジュール編集
  describe "PATCH #update" do
    let!(:schedule) { create(:schedule, user_id: user.id) }
    let!(:other_user) { create(:other_user, department_id: dept.id) }
    let!(:other_user_schedule) { create(:schedule, user_id: other_user.id) }
    let(:valid_params) {
      { "schedule" => {
        "name" => "会議",
        "edit_start_at(4i)" => "03",
        "edit_start_at(5i)" => "00",
        "edit_finish_at(4i)" => "07",
        "edit_finish_at(5i)" => "00" 
      } } 
    }
    let(:invalid_params) {
      { "schedule" => {
        "name" => "会議",
        "edit_start_at(4i)" => "12",
        "edit_start_at(5i)" => "00",
        "edit_finish_at(4i)" => "07",
        "edit_finish_at(5i)" => "00" 
      } } 
    }
    
    context "ログイン済" do
      before { sign_in user }

      context "root_pathからAjax通信かつフォーマットがJS形式の場合" do
        context "パラメータが正の場合" do
          subject {
            patch schedule_path(schedule.id),
                  params: valid_params,
                  headers: valid_header,
                  xhr: true
          }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "スケジュール編集成功" do
            expect do
              subject
            end.to change { 
              Schedule.find(schedule.id).name 
            }.from("#{schedule.name}").to("会議")
          end

          it "編集成功メッセージ表示" do
            subject
            expect(response.body).to include "スケジュールを編集しました。"
          end
        end

        context "パラメータが不正な場合" do
          subject {
            patch schedule_path(schedule.id),
                  params: invalid_params,
                  headers: valid_header,
                  xhr: true
          }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "スケジュール編集失敗" do
            expect do
              subject
            end.not_to change {
              Schedule.find(schedule.id).name
            }
          end

          it "編集失敗メッセージ表示" do
            subject
            expect(response.body).to include "編集に失敗しました。"
          end
        end

        context "他人のスケジュールの場合" do
          subject {
            patch schedule_path(other_user_schedule.id),
                  params: valid_params,
                  headers: valid_header,
                  xhr: true
          }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "スケジュール編集失敗" do
            expect do
              subject
            end.not_to change {
              Schedule.find(other_user_schedule.id).name
            }
          end

          it "編集失敗メッセージ表示" do
            subject
            expect(response.body).to include "編集に失敗しました。"
          end
        end
      end

      context "フォーマットがJS形式以外の場合" do
        it "ルーティングエラー" do
          expect do
            patch schedule_path(schedule.id, format: :html),
                  params: valid_params,
                  headers: valid_header,
                  xhr: true
          end.to raise_error(ActionController::RoutingError)
        end
      end

      context "Ajax通信でない場合" do
        it "ルーティングエラー" do
          expect do
            patch schedule_path(schedule.id, format: :js),
                  params: valid_params,
                  headers: valid_header
          end.to raise_error(ActionController::RoutingError)
        end
      end

      context "root_path以外からの場合" do
        subject {
          patch schedule_path(schedule.id),
                params: valid_params,
                headers: invalid_header,
                xhr: true
        }

        it "リクエスト成功" do
          subject
          expect(response.status).to eq 200
        end

        it "スケジュール編集失敗" do
          expect do
            subject
          end.not_to change {
            Schedule.find(schedule.id).name
          }
        end

        it "root_pathへリダイレクト" do
          subject
          expect(response).to redirect_to root_path
        end
      end
    end

    context "未ログイン" do
      it "認証失敗エラーコードが返ってくること" do
        patch schedule_path(schedule.id),
              params: valid_params,
              headers: valid_header,
              xhr: true
        expect(response.status).to eq 401
      end
    end
  end

  # スケジュール削除
  describe "DELETE #destroy" do
    let!(:schedule) { create(:schedule, user_id: user.id) }
    let!(:other_user) { create(:other_user, department_id: dept.id) }
    let!(:other_user_schedule) { create(:schedule, user_id: other_user.id) }
    
    context "ログイン済" do
      before { sign_in user }

      context "root_pathからAjax通信かつフォーマットがJS形式の場合" do
        context "自分のスケジュールの場合" do
          subject {
            delete schedule_path(schedule.id),
                   headers: valid_header,
                   xhr: true
          }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "スケジュール削除成功" do
            expect do
              subject
            end.to change { Schedule.count }.by(-1)
          end

          it "削除完了メッセージ表示" do
            subject
            expect(response.body).to include "スケジュールを削除しました。"
          end
        end

        context "他人のスケジュールの場合" do
          subject {
            delete schedule_path(other_user_schedule.id),
                   headers: valid_header,
                   xhr: true
          }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "スケジュール削除失敗" do
            expect do
              subject
            end.to change { Schedule.count }.by(0)
          end

          it "削除失敗メッセージ表示" do
            subject
            expect(response.body).to include "削除に失敗しました。"
          end
        end
      end

      context "フォーマットがJS形式以外の場合" do
        it "ルーティングエラー" do
          expect do
            delete schedule_path(schedule.id, format: :html),
                   headers: valid_header,
                   xhr: true
          end.to raise_error(ActionController::RoutingError)
        end
      end

      context "Ajax通信でない場合" do
        it "ルーティングエラー" do
          expect do
            delete schedule_path(schedule.id, format: :js), 
                   headers: valid_header
          end.to raise_error(ActionController::RoutingError)
        end
      end

      context "root_path以外からの場合" do
        subject {
          delete schedule_path(schedule.id),
                 headers: invalid_header,
                 xhr: true
        }

        it "リクエスト成功" do
          subject
          expect(response.status).to eq 200
        end

        it "スケジュール削除失敗" do
          expect do
            subject
          end.to change { Schedule.count }.by(0)
        end

        it "root_pathへリダイレクト" do
          subject
          expect(response).to redirect_to root_path
        end
      end
    end

    context "未ログイン" do
      it "認証失敗エラーコードが返ってくること" do
        delete schedule_path(schedule.id),
               headers: valid_header,
               xhr: true
        expect(response.status).to eq 401
      end
    end
  end
end
