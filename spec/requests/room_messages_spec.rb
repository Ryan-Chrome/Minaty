require "rails_helper"

RSpec.describe "RoomMessage", type: :request do
  let!(:dept) { create(:human_resources_dept) }
  let!(:user) { create(:user, department_id: dept.id) }
  let!(:other_user) { create(:other_user, department_id: dept.id) }
  let!(:meeting_room) { create(:meeting_room) }
  let!(:entry) { meeting_room.users << user }
  let!(:other_room) { create(:meeting_room) }

  let(:valid_params) { { "room_message" => { "meeting_room_id" => "#{meeting_room.public_uid}", "content" => "テストテキスト" } } }
  let(:invalid_room_params) { { "room_message" => { "meeting_room_id" => "#{other_room.public_uid}", "content" => "テストテキスト" } } }
  let(:invalid_long_content_params) { { "room_message" => { "meeting_room_id" => "#{meeting_room.public_uid}", "content" => "#{"a" * 401}" } } }
  let(:invalid_not_content_params) { { "room_message" => { "meeting_room_id" => "#{meeting_room.public_uid}", "content" => "" } } }

  let(:valid_header) { { "HTTP_REFERER" => meeting_room_url(meeting_room.public_uid) } }
  let(:invalid_header) { { "HTTP_REFERER" => root_url } }

  # ルームメッセージ新規作成
  describe "POST #create" do
    
    context "ログイン済" do
      before { sign_in user }

      context "自分のエントリーしているルームからAjax通信かつフォーマットがJS形式の場合" do
        context "パラメータが正の場合" do
          subject {
            post room_messages_path,
                 params: valid_params,
                 headers: valid_header,
                 xhr: true
          }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "メッセージ作成成功" do
            expect do
              subject
            end.to change { RoomMessage.count }.by(1)
          end
        end

        context "ルームIDが不正な場合" do
          subject {
            post room_messages_path,
                 params: invalid_room_params,
                 headers: valid_header,
                 xhr: true
          }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "メッセージ作成失敗" do
            expect do
              subject
            end.to change { RoomMessage.count }.by(0)
          end

          it "エラーメッセージ表示" do
            subject
            expect(response.body).to include "不正な操作がされました。"
          end
        end

        context "メッセージが400文字より長い場合" do
          subject {
            post room_messages_path,
                 params: invalid_long_content_params,
                 headers: valid_header,
                 xhr: true
          }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "メッセージ作成失敗" do
            expect do
              subject
            end.to change { RoomMessage.count }.by(0)
          end

          it "エラーメッセージ表示" do
            subject
            expect(response.body).to include "メッセージは400文字以内で入力してください"
          end
        end

        context "メッセージが空の場合" do
          subject {
            post room_messages_path,
                 params: invalid_not_content_params,
                 headers: valid_header,
                 xhr: true
          }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "メッセージ作成失敗" do
            expect do
              subject
            end.to change { RoomMessage.count }.by(0)
          end

          it "エラーメッセージ表示" do
            subject
            expect(response.body).to include "メッセージを入力してください"
          end
        end
      end

      context "自分のエントリーしているルーム以外からの場合" do
        subject {
          post room_messages_path,
               params: valid_params,
               headers: invalid_header,
               xhr: true
        }

        it "リクエスト成功" do
          subject
          expect(response.status).to eq 200
        end

        it "メッセージ作成失敗" do
          expect do
            subject
          end.to change { RoomMessage.count }.by(0)
        end

        it "root_pathへリダイレクト" do
          subject
          expect(response).to redirect_to root_path
        end
      end

      context "フォーマットがJS形式以外の場合" do
        it "ルーティングエラー" do
          expect do
            post room_messages_path(format: :html),
                 params: valid_params,
                 headers: valid_header,
                 xhr: true
          end.to raise_error(ActionController::RoutingError)
        end
      end

      context "Ajax通信でない場合" do
        it "ルーティングエラー" do
          expect do
            post room_messages_path(format: :js),
                 params: valid_params,
                 headers: valid_header
          end.to raise_error(ActionController::RoutingError)
        end
      end
    end

    context "未ログイン" do
      it "認証失敗エラーコードが返ってくること" do
        post room_messages_path,
             params: valid_params,
             headers: valid_header,
             xhr: true
        expect(response.status).to eq 401
      end
    end
  end
end
