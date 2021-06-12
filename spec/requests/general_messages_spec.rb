require "rails_helper"

RSpec.describe "GeneralMessage", type: :request do
  let!(:dept) { create(:human_resources_dept) }
  let!(:user) { create(:user, department_id: dept.id) }
  let!(:other_user) { create(:other_user, department_id: dept.id) }
  let!(:therd_user) { create(:therd_user, department_id: dept.id) }
  let(:valid_header) { { "HTTP_REFERER" => root_url } }
  let(:invalid_header) { { "HTTP_REFERER" => meeting_rooms_url } }

  # メッセージの送信先一覧表示
  describe "GET #show" do
    let!(:message) { user.general_messages.create(content: "テストテキスト") }
    let!(:message_relation) { message.receive_users << other_user }
    let!(:other_message) { other_user.general_messages.create(content: "テストテキスト") }
    
    context "ログイン済" do
      before { sign_in user }

      context "root_pathからAjax通信かつフォーマットがJS形式の場合" do
        context "正しいメッセージIDの場合" do
          subject {
            get general_message_path(message.id),
                headers: valid_header,
                xhr: true
          }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "メッセージ送信先表示" do
            subject
            expect(response.body).to include "送信先一覧"
          end
        end

        context "正しくないメッセージIDの場合" do
          subject {
            get general_message_path(other_message.id),
                headers: valid_header,
                xhr: true
          }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "メッセージ送信先表示しない" do
            subject
            expect(response.body).not_to include "送信先一覧"
          end
        end
      end

      context "フォーマットがJS形式以外の場合" do
        it "ルーティングエラー" do
          expect do
            get general_message_path(message.id, format: :html),
                headers: valid_header,
                xhr: true
          end.to raise_error(ActionController::RoutingError)
        end
      end

      context "Ajax通信でない場合" do
        it "ルーティングエラー" do
          expect do
            get general_message_path(message.id, format: :js),
                headers: valid_header
          end.to raise_error(ActionController::RoutingError)
        end
      end

      context "root_path以外からの場合" do
        subject {
          get general_message_path(message.id),
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
        get general_message_path(message.id),
            headers: valid_header,
            xhr: true
        expect(response.status).to eq 401
      end
    end
  end

  # メッセージ新規作成
  describe "POST #create" do
    let(:valid_params) { { "general_message" => { "content" => "テストテキスト", "receive_user_id" => "#{other_user.public_uid}" } } }
    let(:invalid_content_params) { { "general_message" => { "content" => "", "receive_user_id" => "#{other_user.public_uid}" } } }
    let(:invalid_user_id_params) { { "general_message" => { "content" => "テストテキスト", "receive_user_id" => "" } } }
    
    context "ログイン済" do
      before { sign_in user }

      context "root_pathからAjax通信かつフォーマットがJS形式の場合" do
        context "パラメータが正の場合" do
          subject {
            post general_messages_path,
                 params: valid_params,
                 headers: valid_header,
                 xhr: true
          }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "メッセージ作成と送信先追加成功" do
            expect do 
              subject
            end.to change {
              GeneralMessage.count
            }.by(1).and change {
              GeneralMessageRelation.count
            }.by(1)
          end

          it "メッセージ表示" do
            subject
            expect(response.body).to include "テストテキスト"
          end
        end

        context "パラメータが正ではない場合" do
          context "パラメータにメッセージ内容が含まれない場合" do
            subject {
              post general_messages_path,
                   params: invalid_content_params,
                   headers: valid_header,
                   xhr: true
            }

            it "リクエスト成功" do
              subject
              expect(response.status).to eq 200
            end

            it "メッセージ作成と送信先追加失敗" do
              expect do
                subject
              end.to change {
                GeneralMessage.count
              }.by(0).and change {
                GeneralMessageRelation.count
              }.by(0)
            end

            it "エラーメッセージ表示" do
              subject
              expect(response.body).to include "送信内容に不備があります。"
            end
          end

          context "パラメータに送信先ユーザーIDが含まれない場合" do
            subject {
              post general_messages_path,
                   params: invalid_user_id_params,
                   headers: valid_header,
                   xhr: true
            }

            it "リクエスト成功" do
              subject
              expect(response.status).to eq 200
            end

            it "メッセージ作成と送信先追加失敗" do
              expect do
                subject
              end.to change {
                GeneralMessage.count
              }.by(0).and change {
                GeneralMessageRelation.count
              }.by(0)
            end

            it "エラーメッセージ表示" do
              subject
              expect(response.body).to include "送信内容に不備があります。"
            end
          end
        end
      end

      context "フォーマットがJS形式以外の場合" do
        it "ルーティングエラー" do
          expect do
            post general_messages_path(format: :html),
                 params: valid_params,
                 headers: valid_header,
                 xhr: true
          end.to raise_error(ActionController::RoutingError)
        end
      end

      context "Ajax通信でない場合" do
        it "ルーティングエラー" do
          expect do
            post general_messages_path(format: :js),
                 params: valid_params,
                 headers: valid_header
          end.to raise_error(ActionController::RoutingError)
        end
      end

      context "root_path以外からの場合" do
        subject {
          post general_messages_path,
               params: valid_params,
               headers: invalid_header,
               xhr: true
        }

        it "リクエスト成功" do
          subject
          expect(response.status).to eq 200
        end

        it "メッセージ作成と送信先追加失敗" do
          expect do
            subject
          end.to change {
            GeneralMessage.count
          }.by(0).and change {
            GeneralMessageRelation.count
          }.by(0)
        end

        it "root_pathへリダイレクト" do
          subject
          expect(response).to redirect_to root_path
        end
      end
    end

    context "未ログイン" do
      it "認証失敗エラーコードが返ってくること" do
        post general_messages_path,
             params: valid_params,
             headers: valid_header,
             xhr: true
        expect(response.status).to eq 401
      end
    end
  end

  # 複数人宛にメッセージを新規作成
  describe "POST #multiple_create" do
    let!(:meeting_room) { create(:meeting_room) }
    let!(:entry) { meeting_room.users << user }
    let(:valid_params) { { "general_message" => { "content" => "テストテキスト" }, "general_message_send_users" => ["#{other_user.public_uid}", "#{therd_user.public_uid}"] } }
    let(:invalid_content_params) { { "general_message" => { "content" => "" }, "general_message_send_users" => ["#{other_user.public_uid}", "#{therd_user.public_uid}"] } }
    let(:invalid_user_id_params) { { "general_message" => { "content" => "テストテキスト" } } }
    let(:meeting_room_header) { { "HTTP_REFERER" => meeting_room_url(meeting_room.public_uid) } }
    
    context "ログイン済" do
      before { sign_in user }

      context "root_pathからAjax通信かつフォーマットがJS形式の場合" do
        context "パラメータが正の場合" do
          subject {
            post general_messages_multiple_create_path,
                 params: valid_params,
                 headers: valid_header,
                 xhr: true
          }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "メッセージ作成と送信先追加成功" do
            expect do
              subject
            end.to change {
              GeneralMessage.count
            }.by(1).and change {
              GeneralMessageRelation.count
            }.by(2)
          end

          it "メッセージ表示" do
            subject
            expect(response.body).to include "テストテキスト"
          end
        end

        context "パラメータが正ではない場合" do
          context "パラメータにメッセージ内容が含まれない場合" do
            subject {
              post general_messages_multiple_create_path,
                   params: invalid_content_params,
                   headers: valid_header,
                   xhr: true
            }

            it "リクエスト成功" do
              subject
              expect(response.status).to eq 200
            end

            it "メッセージ作成と送信先追加失敗" do
              expect do
                subject
              end.to change {
                GeneralMessage.count
              }.by(0).and change {
                GeneralMessageRelation.count
              }.by(0)
            end

            it "エラーメッセージ表示" do
              subject
              expect(response.body).to include "送信先もしくは内容に不備があります。"
            end
          end

          context "パラメータに送信先ユーザーIDが含まれない場合" do
            subject {
              post general_messages_multiple_create_path,
                   params: invalid_user_id_params,
                   headers: valid_header,
                   xhr: true
            }

            it "リクエスト成功" do
              subject
              expect(response.status).to eq 200
            end

            it "メッセージ作成と送信先追加失敗" do
              expect do
                subject
              end.to change {
                GeneralMessage.count
              }.by(0).and change {
                GeneralMessageRelation.count
              }.by(0)
            end

            it "エラーメッセージ表示" do
              subject
              expect(response.body).to include "送信先もしくは内容に不備があります。"
            end
          end
        end
      end

      context "エントリーしているルームからAjax通信かつフォーマットがJS形式の場合" do
        context "パラメータが正の場合" do
          subject {
            post general_messages_multiple_create_path,
                 params: valid_params,
                 headers: meeting_room_header,
                 xhr: true
          }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "メッセージ作成と送信先追加成功" do
            expect do
              subject
            end.to change {
              GeneralMessage.count
            }.by(1).and change {
              GeneralMessageRelation.count
            }.by(2)
          end

          it "メッセージ表示" do
            subject
            expect(response.body).to include "テストテキスト"
          end
        end

        context "パラメータが正ではない場合" do
          context "パラメータにメッセージ内容が含まれない場合" do
            subject {
              post general_messages_multiple_create_path,
                   params: invalid_content_params,
                   headers: valid_header,
                   xhr: true
            }

            it "リクエスト成功" do
              subject
              expect(response.status).to eq 200
            end

            it "メッセージ作成と送信先追加失敗" do
              expect do
                subject
              end.to change {
                GeneralMessage.count
              }.by(0).and change {
                GeneralMessageRelation.count
              }.by(0)
            end

            it "エラーメッセージ表示" do
              subject
              expect(response.body).to include "送信先もしくは内容に不備があります。"
            end
          end

          context "パラメータに送信先ユーザーIDが含まれない場合" do
            subject {
              post general_messages_multiple_create_path,
                   params: invalid_user_id_params,
                   headers: valid_header,
                   xhr: true
            }

            it "リクエスト成功" do
              subject
              expect(response.status).to eq 200
            end

            it "メッセージ作成と送信先追加失敗" do
              expect do
                subject
              end.to change {
                GeneralMessage.count
              }.by(0).and change {
                GeneralMessageRelation.count
              }.by(0)
            end

            it "エラーメッセージ表示" do
              subject
              expect(response.body).to include "送信先もしくは内容に不備があります。"
            end
          end
        end
      end

      context "フォーマットがJS形式以外の場合" do
        it "ルーティングエラー" do
          expect do
            post general_messages_multiple_create_path(format: :html),
                 params: valid_params,
                 headers: valid_header,
                 xhr: true
          end.to raise_error(ActionController::RoutingError)
        end
      end

      context "Ajax通信でない場合" do
        it "ルーティングエラー" do
          expect do
            post general_messages_multiple_create_path(format: :js),
                 params: valid_params,
                 headers: valid_header
          end.to raise_error(ActionController::RoutingError)
        end
      end

      context "root_pathとエントリーしているルーム以外からの場合" do
        subject {
          post general_messages_multiple_create_path,
               params: valid_params,
               headers: invalid_header,
               xhr: true
        }

        it "リクエスト成功" do
          subject
          expect(response.status).to eq 200
        end

        it "メッセージ作成と送信先追加失敗" do
          expect do
            subject
          end.to change {
            GeneralMessage.count
          }.by(0).and change {
            GeneralMessageRelation.count
          }.by(0)
        end

        it "root_pathへリダイレクト" do
          subject
          expect(response).to redirect_to root_path
        end
      end
    end

    context "未ログイン" do
      it "認証失敗エラーコードが返ってくること" do
        post general_messages_multiple_create_path,
             params: valid_params,
             headers: valid_header,
             xhr: true
        expect(response.status).to eq 401
      end
    end
  end

  # ユーザー詳細ページのチャットコンテンツ読み込み(スクロール時)
  describe "GET #message_ajax" do
    let!(:first_message) { user.general_messages.create(content: "２ページ目テキスト") }
    let!(:relation) { first_message.receive_users << other_user }
    let!(:messages) {
      10.times.each do
        message = user.general_messages.create(content: "テスト")
        message.receive_users << other_user
      end
    }
    let(:valid_params) { {"other_user" => "#{other_user.public_uid}", "page" => "2"} }
    let(:invalid_params) { {"other_user" => "#{user.public_uid}", "page" => "2"} }

    context "ログイン済" do
      before { sign_in user }
      
      context "root_pathからAjax通信の場合" do
        context "パラメータが正の場合" do
          subject { 
            get general_messages_other_user_chat_ajax_path,
                params: valid_params,
                headers: valid_header,
                xhr: true
          }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "11番目のメッセージが返ってくること" do
            subject
            expect(response.body).to include "#{first_message.content}"
          end
        end

        context "パラメータが正ではない場合" do
          subject {
            get general_messages_other_user_chat_ajax_path,
                params: invalid_params,
                headers: valid_header,
                xhr: true
          }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "何も返ってこないこと" do
            subject
            expect(response.body).to eq ""
          end
        end
      end

      context "Ajax通信でない場合" do
        it "ルーティングエラー" do
          expect do
            get general_messages_other_user_chat_ajax_path,
                params: valid_params,
                headers: valid_header
          end.to raise_error(ActionController::RoutingError)
        end
      end

      context "root_path以外からの場合" do
        subject {
          get general_messages_other_user_chat_ajax_path,
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
        get general_messages_other_user_chat_ajax_path,
            params: valid_params,
            headers: valid_header,
            xhr: true
        expect(response.status).to eq 401
      end
    end
  end

  # ホームチャットコンテンツの読み込み(スクロール時)
  describe "GET #home_message_ajax" do
    let!(:first_message) { user.general_messages.create(content: "2ページ目テキスト") }
    let!(:relation) { first_message.receive_users << other_user }
    let!(:messages) {
      10.times.each do
        message = user.general_messages.create(content: "テスト")
        message.receive_users << other_user
      end
    }
    let(:valid_params) { {"page" => "2"} }
    let(:invalid_params) { {"page" => "30"} }

    context "ログイン済" do
      before { sign_in user }

      context "root_pathからAjax通信の場合" do
        context "パラメータが正の場合" do
          subject {
            get general_messages_home_chat_ajax_path,
                params: valid_params,
                headers: valid_header,
                xhr: true
          }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "11番目のメッセージが返ってくること" do
            subject
            expect(response.body).to include "#{first_message.content}"
          end
        end

        context "パラメータが正ではない場合" do
          subject {
            get general_messages_home_chat_ajax_path,
                params: invalid_params,
                headers: valid_header,
                xhr: true
          }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "何も返ってこないこと" do
            subject
            expect(response.body).to eq ""
          end
        end
      end

      context "Ajax通信でない場合" do
        it "ルーティングエラー" do
          expect do
            get general_messages_home_chat_ajax_path,
                params: valid_params,
                headers: valid_header
          end.to raise_error(ActionController::RoutingError)
        end
      end

      context "root_path以外からの場合" do
        subject {
          get general_messages_home_chat_ajax_path,
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
        get general_messages_home_chat_ajax_path,
            params: valid_params,
            headers: valid_header,
            xhr: true
        expect(response.status).to eq 401
      end
    end
  end
end
