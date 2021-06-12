require "rails_helper"

RSpec.describe "ContactGroup", type: :request do
  let!(:dept) { create(:human_resources_dept) }
  let!(:user) { create(:user, department_id: dept.id) }
  let!(:other_user) { create(:other_user, department_id: dept.id) }
  let!(:therd_user) { create(:therd_user, department_id: dept.id) }

  let(:valid_header) { { "HTTP_REFERER" => root_url } }
  let(:invalid_header) { { "HTTP_REFERER" => meeting_rooms_url } }

  # コンタクトグループ新規作成
  describe "POST #create" do
    # 有効なパラメータ
    let(:valid_params) {
      { contact_group: {
        name: "テストグループ",
        user_ids: [other_user.public_uid, therd_user.public_uid],
      } }
    }
    # 存在しないユーザーIDが含まれるパラメータ
    let(:params_with_non_existent_user) {
      { contact_group: {
        name: "テストグループ",
        user_ids: [other_user.public_uid, "1234"],
      } }
    }
    # 自分のユーザーIDが含まれるパラメータ
    let(:params_with_current_user_id) {
      { contact_group: {
        name: "テストグループ",
        user_ids: [other_user.public_uid, user.public_uid],
      } }
    }
    # グループ名が含まれないパラメータ
    let(:params_without_name) {
      { contact_group: {
        name: "",
        user_ids: [other_user.public_uid, therd_user.public_uid],
      } }
    }
    # 追加するユーザーIDが含まれないパラメータ
    let(:params_without_user_ids) {
      { contact_group: {
        name: "テストグループ",
      } }
    }

    context "ログイン済" do
      before { sign_in user }

      context "root_pathからAjax通信かつフォーマットがJS形式の場合" do
        context "パラメータが正の場合" do
          subject {
            post contact_groups_path,
                 params: valid_params,
                 headers: valid_header,
                 xhr: true
          }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "グループ作成とユーザーの追加成功" do
            expect do
              subject
            end.to change {
              ContactGroupRelation.count
            }.by(2).and change {
              ContactGroup.count
            }.by(1)
          end

          it "作成完了メッセージ表示" do
            subject
            expect(response.body).to include "テストグループを作成しました。"
          end
        end

        context "パラメータに存在しないユーザーIDが含まれている場合" do
          subject {
            post contact_groups_path,
                 params: params_with_non_existent_user,
                 headers: valid_header,
                 xhr: true
          }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "グループ作成と存在するユーザーのみ追加成功" do
            expect do
              subject
            end.to change {
              ContactGroupRelation.count
            }.by(1).and change {
              ContactGroup.count
            }.by(1)
          end

          it "作成完了メッセージ表示" do
            subject
            expect(response.body).to include "テストグループを作成しました。"
          end
        end

        context "パラメータに自分のIDが含まれている場合" do
          subject {
            post contact_groups_path,
                 params: params_with_current_user_id,
                 headers: valid_header,
                 xhr: true
          }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "グループ作成と自分以外のユーザーのみ追加成功" do
            expect do
              subject
            end.to change {
              ContactGroupRelation.count
            }.by(1).and change {
              ContactGroup.count
            }.by(1)
          end

          it "作成完了メッセージ表示" do
            subject
            expect(response.body).to include "テストグループを作成しました。"
          end
        end

        context "パラメータにグループ名が含まれていない場合" do
          subject {
            post contact_groups_path,
                 params: params_without_name,
                 headers: valid_header,
                 xhr: true
          }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "グループ作成とユーザーの追加失敗" do
            expect do
              subject
            end.to change {
              ContactGroupRelation.count
            }.by(0).and change {
              ContactGroup.count
            }.by(0)
          end

          it "作成失敗メッセージ表示" do
            subject
            expect(response.body).to include "処理に失敗しました。"
          end
        end

        context "パラメータにユーザーIDが含まれていない場合" do
          subject {
            post contact_groups_path,
                 params: params_without_user_ids,
                 headers: valid_header,
                 xhr: true
          }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "グループ作成とユーザーの追加失敗" do
            expect do
              subject
            end.to change {
              ContactGroupRelation.count
            }.by(0).and change { ContactGroup.count }.by(0)
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
            post contact_groups_path(format: :html),
                 params: valid_params,
                 headers: valid_header,
                 xhr: true
          end.to raise_error(ActionController::RoutingError)
        end
      end

      context "Ajax通信でない場合" do
        it "ルーティングエラー" do
          expect do
            post contact_groups_path(format: :js),
                params: valid_params,
                headers: valid_header
          end.to raise_error(ActionController::RoutingError)
        end
      end

      context "root_path以外からの場合" do
        subject {
          post contact_groups_path,
               params: valid_params,
               headers: invalid_header,
               xhr: true
        }

        it "リクエスト成功" do
          subject
          expect(response.status).to eq 200
        end

        it "グループ作成とユーザーの追加失敗" do
          expect do
            subject
          end.to change {
            ContactGroupRelation.count
          }.by(0).and change {
            ContactGroup.count
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
        post contact_groups_path,
             params: valid_params,
             headers: valid_header,
             xhr: true
        expect(response.status).to eq 401
      end
    end
  end

  # コンタクトグループ削除
  describe "DELETE #destroy" do
    let!(:contact_group) { create(:contact_group, user_id: user.id) }
    let!(:contact_group_relation) { contact_group.users << other_user }
    let!(:other_contact_group) { create(:contact_group, user_id: other_user.id) }
    let!(:other_group_relation) { other_contact_group.users << user }

    context "ログイン済" do
      before { sign_in user }

      context "root_pathからAjax通信かつフォーマットがJS形式の場合" do
        context "正しいグループIDの場合" do
          subject {
            delete contact_group_path(contact_group.id),
                   headers: valid_header,
                   xhr: true
          }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "グループとリレーション削除成功" do
            expect do
              subject
            end.to change {
              ContactGroupRelation.count
            }.by(-1).and change {
              ContactGroup.count
            }.by(-1)
          end

          it "削除完了メッセージ表示" do
            subject
            expect(response.body).to include "#{contact_group.name}を削除しました。"
          end
        end

        context "他人のグループIDの場合" do
          subject {
            delete contact_group_path(other_contact_group.id),
                   headers: valid_header,
                   xhr: true
          }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "グループとリレーション削除失敗" do
            expect do
              subject
            end.to change {
              ContactGroupRelation.count
            }.by(0).and change {
              ContactGroup.count
            }.by(0)
          end

          it "削除失敗メッセージ表示" do
            subject
            expect(response.body).to include "処理に失敗しました。"
          end
        end
      end

      context "フォーマットがJS形式以外の場合" do
        it "ルーティングエラー" do
          expect do
            delete contact_group_path(contact_group.id, format: :html), headers: valid_header, xhr: true
          end.to raise_error(ActionController::RoutingError)
        end
      end

      context "Ajax通信でない場合" do
        it "ルーティングエラー" do
          expect do
            delete contact_group_path(contact_group.id, format: :js), headers: valid_header
          end.to raise_error(ActionController::RoutingError)
        end
      end

      context "root_path以外からの場合" do
        subject {
          delete contact_group_path(contact_group.id),
                 headers: invalid_header,
                 xhr: true
        }

        it "リクエスト成功" do
          subject
          expect(response.status).to eq 200
        end

        it "グループとリレーション削除失敗" do
          expect do
            subject
          end.to change {
            ContactGroupRelation.count
          }.by(0).and change {
            ContactGroup.count 
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
        delete contact_group_path(contact_group.id),
               headers: valid_header,
               xhr: true
        expect(response.status).to eq 401
      end
    end
  end
end
