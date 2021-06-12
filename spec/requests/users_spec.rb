require "rails_helper"

RSpec.describe "User", type: :request do
  let!(:dept) { create(:human_resources_dept) }
  let!(:user) { create(:user, department_id: dept.id) }
  let!(:other_user) { create(:other_user, department_id: dept.id) }
  let!(:admin_user) { create(:admin_user, department_id: dept.id) }
  let(:valid_header) { { "HTTP_REFERER" => root_url } }
  let(:invalid_header) { { "HTTP_REFERER" => meeting_rooms_url } }

  # ユーザー検索モーダル
  describe "GET #modal_search" do
    let(:valid_params) { { "department" => "#{dept.id}", "name" => other_user.name } }
    let(:invalid_params) { { "department" => "", "name" => "" } }

    context "ログイン済" do
      before { sign_in user }

      context "root_pathからAjax通信かつフォーマットがJS形式の場合" do
        context "パラメータが正の場合" do
          subject {
            get user_modal_search_path,
                params: valid_params,
                headers: valid_header,
                xhr: true
          }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "検索したユーザーが表示されること" do
            subject
            expect(response.body).to include "ユーザー検索結果"
            expect(response.body).to include "#{other_user.name}"
          end
        end

        context "パラメータが不正な場合" do
          subject {
            get user_modal_search_path,
                params: invalid_params,
                headers: valid_header,
                xhr: true
          }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "該当するユーザーが存在しないことが表示されること" do
            subject
            expect(response.body).to include "該当するユーザーが<br>存在しません"
          end
        end
      end

      context "フォーマットがJS形式以外の場合" do
        it "ルーティングエラー" do
          expect do
            get user_modal_search_path(format: :html),
                params: valid_params,
                headers: valid_header,
                xhr: true
          end.to raise_error(ActionController::RoutingError)
        end
      end

      context "Ajax通信でない場合" do
        it "ルーティングエラー" do
          expect do
            get user_modal_search_path(format: :js),
                params: valid_params,
                headers: valid_header
          end.to raise_error(ActionController::RoutingError)
        end
      end

      context "root_path以外からの場合" do
        subject {
          get user_modal_search_path,
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
        get user_modal_search_path,
            params: valid_params,
            headers: valid_header,
            xhr: true
        expect(response.status).to eq 401
      end
    end
  end

  # ユーザー詳細モーダル
  describe "GET #modal_show" do
    context "ログイン済" do
      before { sign_in user }

      context "root_pathからAjax通信かつフォーマットがJS形式の場合" do
        context "パラメータが他人のユーザーIDの場合" do
          subject {
            get user_modal_show_path(other_user.public_uid),
                headers: valid_header,
                xhr: true
          }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "ユーザー詳細モーダル表示" do
            subject
            expect(response.body).to include "ユーザー詳細"
            expect(response.body).to include "#{other_user.name}"
          end
        end

        context "パラメータが自分のユーザーIDの場合" do
          subject {
            get user_modal_show_path(user.public_uid),
                headers: valid_header,
                xhr: true
          }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "ユーザー詳細モーダル表示されないこと" do
            subject
            expect(response.body).not_to include "ユーザー詳細"
          end
        end

        context "パラメータが不正な場合" do
          subject {
            get user_modal_show_path("test"),
                headers: valid_header,
                xhr: true
          }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "ユーザー詳細モーダル表示されないこと" do
            subject
            expect(response.body).not_to include "ユーザー詳細"
          end
        end
      end

      context "フォーマットがJS形式以外の場合" do
        it "ルーティングエラー" do
          expect do
            get user_modal_show_path(other_user.public_uid, format: :html),
                headers: valid_header,
                xhr: true
          end.to raise_error(ActionController::RoutingError)
        end
      end

      context "Ajax通信でない場合" do
        it "ルーティングエラー" do
          expect do
            get user_modal_show_path(other_user.public_uid, format: :js),
                headers: valid_header
          end.to raise_error(ActionController::RoutingError)
        end
      end

      context "root_path以外からの場合" do
        subject {
          get user_modal_show_path(other_user.public_uid),
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
        get user_modal_show_path(other_user.public_uid),
            headers: valid_header,
            xhr: true
        expect(response.status).to eq 401
      end
    end
  end

  # ダッシュボード
  describe "GET #show" do
    context "ログイン済" do
      context "管理ユーザーの場合" do
        before { sign_in admin_user }

        context "パラメータが自分のユーザーIDの場合"  do
          subject { get user_path(admin_user.public_uid) }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "ダッシュボード表示" do
            subject
            expect(response.body).to include "ダッシュボード"
            expect(response.body).to include "#{admin_user.name}"
          end
        end

        context "パラメータが他のユーザーIDの場合" do
          subject { get user_path(user.public_uid) }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "ダッシュボード表示" do
            subject
            expect(response.body).to include "ダッシュボード"
            expect(response.body).to include "#{user.name}"
          end
        end

        context "パラメータが不正な場合" do
          subject { get user_path("test") }

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

      context "一般ユーザーの場合" do
        before { sign_in user }

        context "パラメータが自分のユーザーIDの場合" do
          subject { get user_path(user.public_uid) }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "ダッシュボード表示" do
            subject
            expect(response.body).to include "ダッシュボード"
            expect(response.body).to include "#{user.name}"
          end
        end

        context "パラメータが他のユーザーIDの場合" do
          subject { get user_path(other_user.public_uid) }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 302
          end

          it "root_pathへリダイレクト" do
            subject
            expect(response).to redirect_to root_path
          end
        end

        context "パラメータが不正な場合" do
          subject { get user_path("test") }

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
    end

    context "未ログイン " do
      subject { get user_path(user.public_uid) }

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

  # ユーザー管理
  describe "GET #index" do
    subject {
      get users_path
    }

    context "ログイン済" do
      context "管理ユーザーの場合" do
        before { sign_in admin_user }

        it "リクエスト成功" do
          subject
          expect(response.status).to eq 200
        end

        it "ユーザー一覧表示" do
          subject
          expect(response.body).to include "ユーザーリスト"
        end
      end

      context "一般ユーザーの場合" do
        before { sign_in user }

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

  # ユーザー管理検索機能
  describe "GET #search" do
    let(:valid_params) { { "department" => "#{dept.id}", "name" => "#{user.name}" } }
    let(:invalid_params) { { "department" => "test", "name" => "not_user" } }

    context "ログイン済" do
      context "管理ユーザーの場合" do
        before { sign_in admin_user }

        context "Ajax通信かつフォーマットがJS形式の場合" do
          context "パラメータが正の場合" do
            subject {
              get user_search_path,
                  params: valid_params,
                  xhr: true
            }

            it "リクエスト成功" do
              subject
              expect(response.status).to eq 200
            end

            it "検索したユーザーが表示されること" do
              subject
              expect(response.body).to include "#{user.name}"
              expect(response.body).to include "#{dept.name}"
            end
          end

          context "パラメータが不正な場合" do
            subject {
              get user_search_path,
                  params: invalid_params,
                  xhr: true
            }

            it "リクエスト成功" do
              subject
              expect(response.status).to eq 200
            end

            it "ユーザーが表示されないこと" do
              subject
              expect(response.body).not_to include "#{dept.name}"
            end
          end
        end

        context "フォーマットがJS形式以外の場合" do
          it "ルーティングエラー" do
            expect do
              get user_search_path(format: :html),
                  params: valid_params,
                  xhr: true
            end.to raise_error(ActionController::RoutingError)
          end
        end

        context "Ajax通信でない場合" do
          it "ルーティングエラー" do
            expect do
              get user_search_path(format: :js),
                  params: valid_params
            end.to raise_error(ActionController::RoutingError)
          end
        end
      end

      context "一般ユーザーの場合" do
        before { sign_in user }

        subject {
          get user_search_path,
              params: valid_params,
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
        get user_search_path,
            params: valid_params,
            xhr: true
        expect(response.status).to eq 401
      end
    end
  end

  # ホーム画面ユーザーリストサイドバー
  describe "GET #sidebar_search" do
    let(:valid_params) { { "department_id" => "#{dept.id}" } }
    let(:invalid_params) { { "department_id" => "" } }

    context "ログイン済" do
      before { sign_in user }

      context "root_pathからAjax通信かつフォーマットがJS形式の場合" do
        context "パラメータが正の場合" do
          subject {
            get user_sidebar_search_path,
                params: valid_params,
                headers: valid_header,
                xhr: true
          }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "検索した部署が表示されること" do
            subject
            expect(response.body).to include "#{dept.name}"
          end
        end

        context "パラメータが不正な場合" do
          subject {
            get user_sidebar_search_path,
                params: invalid_params,
                headers: valid_header,
                xhr: true
          }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "何も表示されないこと" do
            subject
            expect(response.body).to eq "" 
          end
        end
      end

      context "フォーマットがJS形式以外の場合" do
        it "ルーティングエラー" do
          expect do
            get user_sidebar_search_path(format: :html),
                params: valid_params,
                headers: valid_header,
                xhr: true
          end.to raise_error(ActionController::RoutingError)
        end
      end

      context "Ajax通信でない場合" do
        it "ルーティングエラー" do
          expect do
            get user_sidebar_search_path(format: :js),
                params: valid_params,
                headers: valid_header
          end.to raise_error(ActionController::RoutingError)
        end
      end

      context "root_path以外からの場合" do
        subject {
          get user_sidebar_search_path,
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
        get user_sidebar_search_path,
            params: valid_params,
            headers: valid_header,
            xhr: true
        expect(response.status).to eq 401
      end
    end
  end
end
