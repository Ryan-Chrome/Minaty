require "rails_helper"

RSpec.describe "MeetingRoom", type: :request do
  let!(:dept) { create(:human_resources_dept) }
  let!(:user) { create(:user, department_id: dept.id) }
  let!(:other_user) { create(:other_user, department_id: dept.id) }
  let!(:therd_user) { create(:therd_user, department_id: dept.id) }

  # ミーティングルーム表示
  describe "GET #show" do
    let!(:meeting_room) { create(:meeting_room) }
    let!(:entry) { meeting_room.users << user }
    let!(:other_meeting_room) { create(:meeting_room) }

    context "ログイン済" do
      before { sign_in user }

      context "エントリーしているルームの場合" do
        subject { get meeting_room_path(meeting_room.public_uid) }
        
        it "リクエスト成功" do
          subject
          expect(response.status).to eq 200
        end

        it "ルーム表示" do
          subject
          expect(response.body).to include "プレビュー"
        end
      end

      context "エントリーしていないルームの場合" do
        subject { get meeting_room_path(other_meeting_room.public_uid) }

        it "リクエスト成功" do
          subject
          expect(response.status).to eq 302
        end

        it "ルーム一覧へリダイレクト" do
          subject
          expect(response).to redirect_to meeting_rooms_path
        end
      end
    end

    context "未ログイン" do
      subject { get meeting_room_path(meeting_room.public_uid) }

      it "リクエスト成功" do
        subject
        expect(response.status).to eq 302
      end

      it "ログインページへリダイレクト" do
        subject
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  # ミーティングルーム参加
  describe "GET #join" do
    let!(:meeting_room) { create(:meeting_room) }
    let!(:entry) { meeting_room.users << user }
    let(:valid_header) { { "HTTP_REFERER" => meeting_room_url(meeting_room.public_uid) } }
    let(:invalid_header) { { "HTTP_REFERER" => meeting_room_url(other_meeting_room.public_uid) } }
    let!(:other_meeting_room) { create(:meeting_room) }

    context "ログイン済" do
      before { sign_in user }

      context "エントリーしているルームからAjax通信かつフォーマットがJS形式の場合" do
        context "エントリーしているルームIDがURLに含まれる場合" do
          subject {
            get meeting_rooms_join_path(meeting_room.public_uid),
                headers: valid_header,
                xhr: true
          }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "JSコードが返ってくること" do
            subject
            expect(response.body).to include "setting_video"
          end
        end

        context "エントリーしていないルームIDがURLに含まれる場合" do
          subject {
            get meeting_rooms_join_path(other_meeting_room.public_uid),
                headers: valid_header,
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

      context "エントリーしていないルームからの場合" do
        subject {
          get meeting_rooms_join_path(meeting_room.public_uid),
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

      context "フォーマットがJS形式以外の場合" do
        it "ルーティングエラー" do
          expect do
            get meeting_rooms_join_path(meeting_room.public_uid, format: :html),
                headers: valid_header,
                xhr: true
          end.to raise_error(ActionController::RoutingError)
        end
      end

      context "Ajax通信でない場合" do
        it "ルーティングエラー" do
          expect do
            get meeting_rooms_join_path(meeting_room.public_uid, format: :js),
                headers: valid_header
          end.to raise_error(ActionController::RoutingError)
        end
      end
    end

    context "未ログイン" do
      it "認証失敗エラーコードが返ってくること" do
        get meeting_rooms_join_path(meeting_room.public_uid),
            headers: valid_header,
            xhr: true
        expect(response.status).to eq 401
      end
    end
  end

  # ミーティング一覧
  describe "GET #index" do
    let!(:meeting_room) { create(:meeting_room) }
    let!(:entry) { meeting_room.users << user }

    subject { get meeting_rooms_path }
    
    context "ログイン済" do
      before { sign_in user }

      it "リクエスト成功" do
        subject
        expect(response.status).to eq 200
      end

      it "ルーム一覧を表示" do
        subject
        expect(response.body).to include "#{meeting_room.name}"
      end
    end

    context "未ログイン" do
      it "リクエスト成功" do
        subject
        expect(response.status).to eq 302
      end

      it "ログインページへリダイレクト" do
        subject
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  # ミーティングルーム新規作成フォーム
  describe "GET #new" do
    subject { get new_meeting_room_path }

    context "ログイン済" do
      before { sign_in user }

      it "リクエスト成功" do
        subject
        expect(response.status).to eq 200
      end

      it "ルーム新規作成画面表示" do
        subject
        expect(response.body).to include "ルーム作成"
      end
    end

    context "未ログイン" do
      it "リクエスト成功" do
        subject
        expect(response.status).to eq 302
      end

      it "ログインページへリダイレクト" do
        subject
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  # ミーティングルーム新規作成
  describe "POST #create" do
    # 有効なパラメータ
    let(:valid_params) {
      { "meeting_room" => {
        "name" => "テスト会議",
        "start_at(4i)" => "10",
        "start_at(5i)" => "00",
        "finish_at(4i)" => "17",
        "finish_at(5i)" => "00",
        "meeting_date" => "#{Date.today}",
        "room_entry_users" => ["#{other_user.public_uid}", "#{therd_user.public_uid}"],
      } }
    }
    # ルーム名が空のパラメータ
    let(:invalid_name_params) {
      { "meeting_room" => {
        "name" => "",
        "start_at(4i)" => "10",
        "start_at(5i)" => "00",
        "finish_at(4i)" => "17",
        "finish_at(5i)" => "00",
        "meeting_date" => "#{Date.today}",
        "room_entry_users" => ["#{other_user.public_uid}", "#{therd_user.public_uid}"],
      } }
    }
    # 開始時間が空のパラメータ
    let(:invalid_start_params) {
      { "meeting_room" => {
        "name" => "テスト会議",
        "start_at(4i)" => "",
        "start_at(5i)" => "",
        "finish_at(4i)" => "17",
        "finish_at(5i)" => "00",
        "meeting_date" => "#{Date.today}",
        "room_entry_users" => ["#{other_user.public_uid}", "#{therd_user.public_uid}"],
      } }
    }
    # 終了時間が空のパラメータ
    let(:invalid_finish_params) {
      { "meeting_room" => {
        "name" => "テスト会議",
        "start_at(4i)" => "10",
        "start_at(5i)" => "00",
        "finish_at(4i)" => "",
        "finish_at(5i)" => "",
        "meeting_date" => "#{Date.today}",
        "room_entry_users" => ["#{other_user.public_uid}", "#{therd_user.public_uid}"],
      } }
    }
    # 開始時間が終了時刻より遅いパラメータ
    let(:invalid_start_finish_params) {
      { "meeting_room" => {
        "name" => "テスト会議",
        "start_at(4i)" => "23",
        "start_at(5i)" => "00",
        "finish_at(4i)" => "10",
        "finish_at(5i)" => "00",
        "meeting_date" => "#{Date.today}",
        "room_entry_users" => ["#{other_user.public_uid}", "#{therd_user.public_uid}"]
      } }
    }
    # 日付が空のパラメータ
    let(:invalid_date_params) {
      { "meeting_room" => {
        "name" => "テスト会議",
        "start_at(4i)" => "10",
        "start_at(5i)" => "00",
        "finish_at(4i)" => "17",
        "finish_at(5i)" => "00",
        "meeting_date" => "",
        "room_entry_users" => ["#{other_user.public_uid}", "#{therd_user.public_uid}"],
      } }
    }
    # エントリーユーザーが空のパラメータ
    let(:invalid_entries_params) {
      { "meeting_room" => {
        "name" => "テスト会議",
        "start_at(4i)" => "10",
        "start_at(5i)" => "00",
        "finish_at(4i)" => "17",
        "finish_at(5i)" => "00",
        "meeting_date" => "#{Date.today}",
      } }
    }

    context "ログイン済" do
      before { sign_in user }

      context "パラメータが正の場合" do
        subject { post meeting_rooms_path, params: valid_params }

        it "リクエスト成功" do
          subject
          expect(response.status).to eq 302
        end

        it "ルーム作成成功" do
          expect do
            subject
          end.to change {
            MeetingRoom.count
          }.by(1).and change {
            Entry.count
          }.by(3).and change {
            GeneralMessage.count
          }.by(1).and change {
            GeneralMessageRelation.count
          }.by(2)
        end

        it "ルーム一覧ページへリダイレクト" do
          subject
          expect(response).to redirect_to meeting_rooms_path
        end
      end

      context "パラメータが正ではない場合" do
        context "ルーム名が空の場合" do
          subject { post meeting_rooms_path, params: invalid_name_params }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "ルーム作成失敗" do
            expect do
              subject
            end.to change {
              MeetingRoom.count
            }.by(0).and change {
              Entry.count
            }.by(0).and change {
              GeneralMessage.count
            }.by(0).and change {
              GeneralMessageRelation.count
            }.by(0)
          end

          it "field_with_errorsが存在すること" do
            subject
            expect(response.body).to include "field_with_errors"
          end
        end

        context "開始時間が空の場合" do
          subject { post meeting_rooms_path, params: invalid_start_params }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "ルーム作成失敗" do
            expect do
              subject
            end.to change {
              MeetingRoom.count
            }.by(0).and change {
              Entry.count
            }.by(0).and change {
              GeneralMessage.count
            }.by(0).and change {
              GeneralMessageRelation.count
            }.by(0)
          end

          it "field_with_errorsが存在すること" do
            subject
            expect(response.body).to include "field_with_errors"
          end
        end

        context "終了時間が空の場合" do
          subject { post meeting_rooms_path, params: invalid_finish_params }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "ルーム作成失敗" do
            expect do
              subject
            end.to change {
              MeetingRoom.count
            }.by(0).and change {
              Entry.count
            }.by(0).and change {
              GeneralMessage.count
            }.by(0).and change {
              GeneralMessageRelation.count
            }.by(0)
          end

          it "field_with_errorsが存在すること" do
            subject
            expect(response.body).to include "field_with_errors"
          end
        end

        context "開始時間が終了時間より遅い場合" do
          subject { post meeting_rooms_path, params: invalid_start_finish_params }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "ルーム作成失敗" do
            expect do
              subject
            end.to change {
              MeetingRoom.count
            }.by(0).and change {
              Entry.count
            }.by(0).and change {
              GeneralMessage.count
            }.by(0).and change {
              GeneralMessageRelation.count
            }.by(0)
          end

          it "field_with_errorsが存在すること" do
            subject
            expect(response.body).to include "field_with_errors"
          end
        end

        context "日付が空の場合" do
          subject { post meeting_rooms_path, params: invalid_date_params }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "ルーム作成失敗" do
            expect do
              subject
            end.to change {
              MeetingRoom.count
            }.by(0).and change {
              Entry.count
            }.by(0).and change {
              GeneralMessage.count
            }.by(0).and change {
              GeneralMessageRelation.count
            }.by(0)
          end

          it "field_with_errorsが存在すること" do
            subject
            expect(response.body).to include "field_with_errors"
          end
        end

        context "エントリーユーザーが空の場合" do
          subject { post meeting_rooms_path, params: invalid_entries_params }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "ルーム作成失敗" do
            expect do
              subject
            end.to change {
              MeetingRoom.count
            }.by(0).and change {
              Entry.count
            }.by(0).and change {
              GeneralMessage.count
            }.by(0).and change {
              GeneralMessageRelation.count
            }.by(0)
          end

          it "field_with_errorsが存在すること" do
            subject
            expect(response.body).to include "参加するユーザーを<br>選択してください"
          end
        end
      end
    end

    context "未ログイン" do
      subject { post meeting_rooms_path, params: valid_params }

      it "リクエスト成功" do
        subject
        expect(response.status).to eq 302
      end

      it "ルーム作成失敗" do
        expect do
          subject
        end.to change {
          MeetingRoom.count
        }.by(0).and change {
          Entry.count
        }.by(0).and change {
          GeneralMessage.count
        }.by(0).and change {
          GeneralMessageRelation.count
        }.by(0)
      end

      it "ログインページへリダイレクト" do
        subject
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  # ミーティングルーム削除
  describe "DELETE #destroy" do
    let!(:meeting_room) { create(:meeting_room) }
    let!(:entry) { meeting_room.users << [user, other_user, therd_user] }
    let!(:room_message) { meeting_room.room_messages.create(content: "テスト", user_id: user.id) }
    let!(:other_meeting_room) { create(:meeting_room) }

    let(:meeting_rooms_header) { { "HTTP_REFERER" => meeting_rooms_url } }
    let(:past_rooms_header) { { "HTTP_REFERER" => meeting_rooms_past_index_url } }
    let(:invalid_header) { { "HTTP_REFERER" => root_path } }
  
    context "ログイン済" do
      before { sign_in user }

      context "ルーム一覧からの場合" do
        context "パラメータが正の場合" do
          subject {
            delete meeting_room_path(meeting_room.public_uid),
                   headers: meeting_rooms_header
          }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 302
          end

          it "ルームに関するデータが削除されること" do
            expect do
              subject
            end.to change {
              MeetingRoom.count
            }.by(-1).and change {
              Entry.count
            }.by(-3).and change {
              RoomMessage.count
            }.by(-1)
          end

          it "ルーム一覧へリダイレクト" do
            subject
            expect(response).to redirect_to meeting_rooms_path
          end
        end

        context "パラメータのルームIDがエントリーしていないルームの場合" do
          subject {
            delete meeting_room_path(other_meeting_room.public_uid),
                   headers: meeting_rooms_header
          }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 302
          end

          it "ルームに関するデータが削除されないこと" do
            expect do
              subject
            end.to change {
              MeetingRoom.count
            }.by(0).and change {
              Entry.count
            }.by(0).and change {
              RoomMessage.count
            }.by(0)
          end

          it "ルーム一覧へリダイレクト" do
            subject
            expect(response).to redirect_to meeting_rooms_path
          end
        end
      end

      context "過去ルーム一覧からの場合" do
        subject {
          delete meeting_room_path(meeting_room.public_uid),
                 headers: past_rooms_header
        }

        it "リクエスト成功" do
          subject
          expect(response.status).to eq 302
        end

        it "ルームに関するデータが削除されないこと" do
          expect do
            subject
          end.to change {
            MeetingRoom.count
          }.by(-1).and change {
            Entry.count
          }.by(-3).and change {
            RoomMessage.count
          }.by(-1)
        end

        it "過去ルーム一覧へリダイレクト" do
          subject
          expect(response).to redirect_to meeting_rooms_past_index_path
        end
      end

      context "ルーム一覧と過去ルーム一覧以外からの場合" do
        subject {
          delete meeting_room_path(meeting_room.public_uid),
                 headers: invalid_header
        }

        it "リクエスト成功" do
          subject
          expect(response.status).to eq 302
        end

        it "ルームに関するデータが削除されないこと" do
          expect do
            subject
          end.to change {
            MeetingRoom.count
          }.by(0).and change {
            Entry.count
          }.by(0).and change {
            RoomMessage.count
          }.by(0)
        end

        it "root_pathへリダイレクト" do
          subject
          expect(response).to redirect_to root_path
        end
      end
    end

    context "未ログイン" do
      subject {
        delete meeting_room_path(meeting_room.public_uid),
               headers: meeting_rooms_header
      }

      it "リクエスト成功" do
        subject
        expect(response.status).to eq 302
      end

      it "ルームに関するデータが削除されないこと" do
        expect do
          subject
        end.to change {
          MeetingRoom.count
        }.by(0).and change {
          Entry.count
        }.by(0).and change {
          RoomMessage.count
        }.by(0)
      end

      it "ログインページへリダイレクト" do
        subject
        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end
