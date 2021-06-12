require "rails_helper"

RSpec.describe "ContactGroupRelation", type: :request do
  let!(:dept) { create(:human_resources_dept) }
  let!(:user) { create(:user, department_id: dept.id) }
  let!(:other_user) { create(:other_user, department_id: dept.id) }
  let!(:therd_user) { create(:therd_user, department_id: dept.id) }
  let!(:contact_group) { create(:contact_group, user_id: user.id) }
  let!(:other_contact_group) { create(:contact_group, user_id: other_user.id) }
  let!(:contact_group_relation) { contact_group.users << therd_user }

  let(:valid_header) { { "HTTP_REFERER" => root_url } }
  let(:invalid_header) { { "HTTP_REFERER" => meeting_rooms_url } }

  # コンタクトグループリレーション新規作成
  describe "POST #create" do
    # 有効なパラメータ
    let(:valid_params) {
      { contact_group_relation: {
        contact_group_id: contact_group.id,
        user_id: other_user.public_uid,
      } }
    }
    # 他人のグループIDが含まれるパラメータ
    let(:params_with_other_group_id) {
      { contact_group_relation: {
        contact_group_id: other_contact_group.id,
        user_id: other_user.public_uid,
      } }
    }
    # 自分のユーザーIDが含まれるパラメータ
    let(:params_with_current_user_id) {
      { contact_group_relation: {
        contact_group_id: contact_group.id,
        user_id: user.public_uid,
      } }
    }
    # 既に登録されているリレーションのパラメータ
    let(:registered_params) {
      { contact_group_relation: {
        contact_group_id: contact_group.id,
        user_id: therd_user.public_uid,
      } }
    }

    context "ログイン済" do
      before { sign_in user }

      context "root_pathからAjax通信かつフォーマットがJS形式の場合" do
        context "パラメータが正の場合" do
          subject {
            post contact_group_relations_path,
                 params: valid_params,
                 headers: valid_header,
                 xhr: true
          }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "リレーション作成成功" do
            expect do
              subject
            end.to change { ContactGroupRelation.count }.by(1)
          end

          it "追加完了メッセージ表示" do
            subject
            expect(response.body).to include "#{contact_group.name}に追加しました。"
          end
        end

        context "パラメータが不正な場合" do
          context "パラメータに他ユーザーのグループIDが含まれていた場合" do
            subject {
              post contact_group_relations_path,
                  params: params_with_other_group_id,
                  headers: valid_header,
                  xhr: true
            }

            it "リクエスト成功" do
              subject
              expect(response.status).to eq 200
            end

            it "リレーション作成失敗" do
              expect do
                subject
              end.to change { ContactGroupRelation.count }.by(0)
            end

            it "追加失敗メッセージ表示" do
              subject
              expect(response.body).to include "処理に失敗しました。"
            end
          end

          context "パラメータに自分のIDが含まれている場合" do
            subject {
              post contact_group_relations_path,
                  params: params_with_current_user_id,
                  headers: valid_header,
                  xhr: true
            }

            it "リクエスト成功" do
              subject
              expect(response.status).to eq 200
            end

            it "リレーション作成失敗" do
              expect do
                subject
              end.to change { ContactGroupRelation.count }.by(0)
            end

            it "追加失敗メッセージ表示" do
              subject
              expect(response.body).to include "処理に失敗しました。"
            end
          end

          context "既に存在するリレーションのパラメータの場合" do
            subject {
              post contact_group_relations_path,
                  params: registered_params,
                  headers: valid_header,
                  xhr: true
            }

            it "リクエスト成功" do
              subject
              expect(response.status).to eq 200
            end

            it "リレーション作成失敗" do
              expect do
                subject
              end.to change { ContactGroupRelation.count }.by(0)
            end

            it "追加失敗メッセージ表示" do
              subject
              expect(response.body).to include "処理に失敗しました。"
            end
          end
        end
      end

      context "フォーマットがJS形式以外の場合" do
        it "ルーティングエラー" do
          expect do
            post contact_group_relations_path(format: :html),
                 params: valid_params,
                 headers: valid_header,
                 xhr: true
          end.to raise_error(ActionController::RoutingError)
        end
      end

      context "Ajax通信でない場合" do
        it "ルーティングエラー" do
          expect do
            post contact_group_relations_path(format: :js),
                 params: valid_params,
                 headers: valid_header
          end.to raise_error(ActionController::RoutingError)
        end
      end

      context "root_path以外からの場合" do
        subject {
          post contact_group_relations_path,
               params: valid_params,
               headers: invalid_header,
               xhr: true
        }

        it "リクエスト成功" do
          subject
          expect(response.status).to eq 200
        end

        it "リレーション作成失敗" do
          expect do
            subject
          end.to change { ContactGroupRelation.count }.by(0)
        end

        it "root_pathへリダイレクト" do
          subject
          expect(response).to redirect_to root_path
        end
      end
    end

    context "未ログイン" do
      it "認証失敗エラーコードが返ってくること" do
        post contact_group_relations_path,
             params: valid_params,
             headers: valid_header,
             xhr: true
        expect(response.status).to eq 401
      end
    end
  end
end
