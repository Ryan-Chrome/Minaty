require "rails_helper"

RSpec.describe "Attendances", type: :request do
  let!(:dept) { create(:human_resources_dept) }
  let!(:user) { create(:user, department_id: dept.id) }

  # 出勤レコード新規作成
  describe "POST #create" do
    context "ログイン済" do
      before { sign_in user }

      context "Ajax通信かつフォーマットがJS形式の場合" do
        context "出勤済でない場合" do
          subject { post attendances_path, xhr: true }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "勤怠データ作成成功" do
            expect do
              subject
            end.to change { Attendance.count }.by(1)
          end

          it "出勤時間表示" do
            subject
            expect(response.body).to include "出勤時間"
          end
        end

        context "出勤済の場合" do
          let!(:attendance) { create(:attendance, user_id: user.id) }
          subject { post attendances_path, xhr: true }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "勤怠データ作成失敗" do
            expect do
              subject
            end.to change { Attendance.count }.by(0)
          end

          it "エラーメッセージ表示" do
            subject
            expect(response.body).to include "打刻に失敗しました"
          end
        end
      end

      context "フォーマットがJS形式以外の場合" do
        it "ルーティングエラー" do
          expect do
            post attendances_path(format: :html), xhr: true
          end.to raise_error(ActionController::RoutingError)
        end
      end

      context "Ajax通信でない場合" do
        it "ルーティングエラー" do
          expect do
            post attendances_path(format: :js)
          end.to raise_error(ActionController::RoutingError)
        end
      end
    end

    context "未ログイン" do
      it "認証失敗エラーコードが返ってくること" do
        post attendances_path, xhr: true
        expect(response.status).to eq 401
      end
    end
  end

  # 退勤打刻
  describe "PATCH #update" do
    context "ログイン済" do
      before { sign_in user }

      context "Ajax通信かつフォーマットがJS形式の場合" do
        context "出勤済の場合" do
          let!(:attendance) { create(:attendance, user_id: user.id) }
          subject { patch attendance_path(attendance.id), xhr: true }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "退勤時間更新成功" do
            expect do
              subject
            end.to change { Attendance.find(attendance.id).left_at }
          end

          it "退勤時間表示" do
            subject
            expect(response.body).to include "退勤時間"
          end
        end

        context "退勤済の場合" do
          let!(:attendance) { create(:attendance, user_id: user.id, left_at: DateTime.now) }
          subject { patch attendance_path(attendance.id), xhr: true }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "退勤時間更新失敗" do
            expect do
              subject
            end.not_to change { Attendance.find(attendance.id).left_at }
          end

          it "エラーメッセージ表示" do
            subject
            expect(response.body).to include "既に退勤時間は打刻されています"
          end
        end

        context "出勤済でない場合" do
          subject { patch attendance_path(1), xhr: true }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "エラーメッセージ表示" do
            subject
            expect(response.body).to include "出勤時間が打刻されていません"
          end
        end
      end

      context "フォーマットがJS形式以外の場合" do
        let!(:attendance) { create(:attendance, user_id: user.id) }

        it "ルーティングエラー" do
          expect do
            patch attendance_path(attendance.id, format: :html), xhr: true
          end.to raise_error(ActionController::RoutingError)
        end
      end

      context "Ajax通信でない場合" do
        let!(:attendance) { create(:attendance, user_id: user.id) }

        it "ルーティングエラー" do
          expect do
            patch attendance_path(attendance.id, format: :js)
          end.to raise_error(ActionController::RoutingError)
        end
      end
    end

    context "未ログイン" do
      let!(:attendance) { create(:attendance, user_id: user.id) }

      it "認証失敗エラーコードが返ってくること" do
        patch attendance_path(attendance.id), xhr: true
        expect(response.status).to eq 401
      end
    end
  end

  # 勤怠情報一覧
  describe "GET #index" do
    let!(:admin_user) { create(:admin_user, department_id: dept.id) }
    subject { get attendances_path }

    context "ログイン済" do
      context "管理ユーザーの場合" do
        before { sign_in admin_user }

        it "リクエスト成功" do
          subject
          expect(response.status).to eq 200
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

  # 勤怠情報一覧検索
  describe "GET #search" do
    let!(:admin_user) { create(:admin_user, department_id: dept.id) }
    subject { get attendances_search_path, xhr: true }

    context "ログイン済" do
      context "管理ユーザーの場合" do
        before { sign_in admin_user }

        context "Ajax通信かつフォーマットがJS形式の場合" do
          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "勤怠データテーブル更新" do
            subject
            expect(response.body).to include "#{admin_user.name}"
            expect(response.body).to include "#{user.name}"
          end
        end

        context "フォーマットがJS形式以外の場合" do
          it "ルーティングエラー" do
            expect do
              get attendances_search_path(format: :html), xhr: true
            end.to raise_error(ActionController::RoutingError)
          end
        end

        context "Ajax通信でない場合" do
          it "ルーティングエラー" do
            expect do
              get attendances_search_path(format: :js)
            end.to raise_error(ActionController::RoutingError)
          end
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
      it "認証失敗エラーコードが返ってくること" do
        subject
        expect(response.status).to eq 401
      end
    end
  end

  # 勤怠データダウンロード
  describe "GET #csv_download" do
    let!(:admin_user) { create(:admin_user, department_id: dept.id) }
    let(:valid_params) { {
      sort: "department",
      holiday: "1",
      name: "",
      department: "",
      start_date: "#{Date.today}",
      finish_date: "#{Date.today + 7.day}"
    } }
    let(:invalid_params) { {
      sort: "department",
      holiday: "1",
      name: "",
      department: "",
      start_date: "#{Date.today + 7.day}",
      finish_date: "#{Date.today}"
    } }

    context "ログイン済" do
      context "管理ユーザーの場合" do
        before { sign_in admin_user }

        context "フォーマットがCSV形式の場合" do
          context "パラメータが正の場合" do
            subject { get attendances_csv_download_path(format: :csv), params: valid_params }

            it "リクエスト成功" do
              subject
              expect(response.status).to eq 200
            end

            it "CSVファイルダウンロード成功" do
              subject
              expect(response.headers["Content-Type"]).to include "text/csv"
            end
          end

          context "パラメータが不正な場合" do
            it "CSVファイルダウンロードされない" do
              get attendances_csv_download_path(format: :csv), params: invalid_params
              expect(response.headers["Content-Type"]).to be_nil
            end
          end
        end

        context "フォーマットがCSV形式以外の場合" do
          it "ルーティングエラー" do
            expect do
              get attendances_csv_download_path, params: valid_params
            end.to raise_error(ActionController::RoutingError)
          end
        end
      end

      context "一般ユーザーの場合" do
        before { sign_in user }
        subject { get attendances_csv_download_path(format: :csv), params: valid_params }

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
        get attendances_csv_download_path(format: :csv), params: valid_params
        expect(response.status).to eq 401
      end
    end
  end
end
