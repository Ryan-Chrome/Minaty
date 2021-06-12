require "rails_helper"

RSpec.describe "Entry", type: :request do
  let!(:dept) { create(:human_resources_dept) }
  let!(:user) { create(:user, department_id: dept.id) }
  let!(:other_user) { create(:other_user, department_id: dept.id) }
  let!(:therd_user) { create(:therd_user, department_id: dept.id) }
  let!(:meeting_room) { create(:meeting_room) }
  let!(:entry) { meeting_room.users << user }
  let!(:other_room) { create(:meeting_room) }

  # パラメータ、ヘッダー関連
  let(:valid_params) { { "entry" => { "user_id" => "#{other_user.public_uid}", "meeting_room_id" => "#{meeting_room.public_uid}" } } }
  let(:invalid_room) { { "entry" => { "user_id" => "#{other_user.public_uid}", "meeting_room_id" => "#{other_room.public_uid}" } } }
  let(:invalid_user) { { "entry" => { "user_id" => "#{user.public_uid}", "meeting_room_id" => "#{meeting_room.public_uid}" } } }
  let(:valid_header) { { "HTTP_REFERER" => meeting_room_url(meeting_room.public_uid) } }
  let(:invalid_header) { { "HTTP_REFERER" => root_url } }

  # ミーティングルームへの招待
  describe "POST #create" do
    context "ログイン済" do
      before { sign_in user }

      context "自分の持つミーティングルームからAjax通信かつフォーマットがJS形式の場合" do
        context "パラメータが正の場合" do
          subject {
            post entries_path,
                 params: valid_params,
                 headers: valid_header,
                 xhr: true
          }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "ユーザー追加成功&&招待メッセージ送信完了" do
            expect do
              subject
            end.to change {
              Entry.count
            }.by(1).and change {
              GeneralMessage.count
            }.by(1).and change {
              GeneralMessageRelation.count
            }.by(1)
          end
        end

        context "パラメータに自分がエントリーしている以外のルームIDが含まれる場合" do
          subject {
            post entries_path,
                 params: invalid_room,
                 headers: valid_header,
                 xhr: true
          }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "ユーザー追加失敗&&招待メッセージ送信失敗" do
            expect do
              subject
            end.to change {
              Entry.count
            }.by(0).and change {
              GeneralMessage.count
            }.by(0).and change {
              GeneralMessageRelation.count
            }.by(0)
          end

          it "招待失敗エラーメッセージ表示" do
            subject
            expect(response.body).to include "招待できませんでした。"
          end
        end

        context "パラメータに既にエントリーしているユーザーIDが含まれる場合" do
          subject {
            post entries_path,
                 params: invalid_user,
                 headers: valid_header,
                 xhr: true
          }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "ユーザー追加失敗&&招待メッセージ送信失敗" do
            expect do
              subject
            end.to change {
              Entry.count
            }.by(0).and change {
              GeneralMessage.count
            }.by(0).and change {
              GeneralMessageRelation.count
            }.by(0)
          end

          it "招待失敗エラーメッセージ表示" do
            subject
            expect(response.body).to include "招待できませんでした。"
          end
        end
      end

      context "フォーマットがJS形式以外の場合" do
        it "ルーティングエラー" do
          expect do
            post entries_path(format: :html),
                 params: valid_params,
                 headers: valid_header,
                 xhr: true
          end.to raise_error(ActionController::RoutingError)
        end
      end

      context "Ajax通信でない場合" do
        it "ルーティングエラー" do
          expect do
            post entries_path(format: :js),
                 params: valid_params,
                 headers: valid_header
          end.to raise_error(ActionController::RoutingError)
        end
      end

      context "自分のエントリーしているルーム以外からの場合" do
        subject {
          post entries_path,
               params: valid_params,
               headers: invalid_header,
               xhr: true
        }

        it "リクエスト成功" do
          subject
          expect(response.status).to eq 200
        end

        it "ユーザー追加失敗&&招待メッセージ送信失敗" do
          expect do
            subject
          end.to change {
            Entry.count
          }.by(0).and change {
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
        post entries_path,
             params: valid_params,
             headers: valid_header,
             xhr: true
        expect(response.status).to eq 401
      end
    end
  end
end
