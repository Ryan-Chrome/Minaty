require "rails_helper"

RSpec.describe "Departments", type: :request do
  let!(:dept) { create(:human_resources_dept) }
  let!(:admin_user) { create(:admin_user, department_id: dept.id) }
  let!(:user) { create(:user, department_id: dept.id) }

  # 部署新規作成フォーム
  describe "GET #new" do
    subject { get new_department_path }

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

  # 部署新規登録
  describe "POST #create" do
    let(:valid_params) { attributes_for(:sales_dept) }
    let(:invalid_params) { attributes_for(:human_resources_dept) }

    context "ログイン済" do
      context "管理ユーザーの場合" do
        before { sign_in admin_user }

        context "パラメータが正の場合" do
          subject { post departments_path, params: { department: valid_params } }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 302
          end

          it "部署登録成功" do
            expect do
              subject
            end.to change { Department.count }.by(1)
          end

          it "部署新規登録ページへリダイレクト" do
            subject
            expect(response).to redirect_to new_department_path
          end
        end

        context "パラメータが不正な場合" do
          subject { post departments_path, params: { department: { name: "" } } }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "部署登録失敗" do
            expect do
              subject
            end.to change { Department.count }.by(0)
          end

          it "フォームに'field_with_errors'があること" do
            subject
            expect(response.body).to include "field_with_errors"
          end
        end

        context "登録されている部署と同じ部署名の場合" do
          subject { post departments_path, params: { department: invalid_params } }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "部署登録失敗" do
            expect do
              subject
            end.to change { Department.count }.by(0)
          end

          it "フォームに'field_with_errors'があること" do
            subject
            expect(response.body).to include "field_with_errors"
          end
        end
      end

      context "一般ユーザーの場合" do
        before { sign_in user }
        subject { post departments_path, params: { department: valid_params } }

        it "リクエスト成功" do
          subject
          expect(response.status).to eq 302
        end

        it "部署登録失敗" do
          expect do
            subject
          end.to change { Department.count }.by(0)
        end

        it "root_pathへリダイレクト" do
          subject
          expect(response).to redirect_to root_path
        end
      end
    end

    context "未ログイン" do
      subject { post departments_path, params: { department: valid_params } }

      it "リクエスト成功" do
        subject
        expect(response.status).to eq 302
      end

      it "部署登録失敗" do
        expect do
          subject
        end.to change { Department.count }.by(0)
      end

      it "ログインページへリダイレクト" do
        subject
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  # 登録済部署編集ページ
  describe "GET #edit" do
    context "ログイン済" do
      context "管理ユーザーの場合" do
        before { sign_in admin_user }

        context "正しい部署IDの場合" do
          subject { get edit_department_path(dept.id) }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "部署編集ページ表示" do
            subject
            expect(response.body).to include "部署編集"
          end
        end

        context "存在しない部署IDの場合" do
          subject { get edit_department_path(dept.id + 1) }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 302
          end

          it "部署新規登録ページへリダイレクト" do
            subject
            expect(response).to redirect_to new_department_path
          end
        end
      end

      context "一般ユーザーの場合" do
        before { sign_in user }
        subject { get edit_department_path(dept.id) }

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
      subject { get edit_department_path(dept.id) }

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

  # 登録済部署編集
  describe "PATCH #update" do
    let!(:sales_dept) { create(:sales_dept) }
    let!(:registered_params) { attributes_for(:sales_dept) }

    context "ログイン済" do
      context "管理ユーザーの場合" do
        before { sign_in admin_user }

        context "パラメータが正の場合" do
          subject { patch department_path(dept.id), params: { department: { name: "開発部" } } }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 302
          end

          it "部署名更新成功" do
            expect do
              subject
            end.to change { 
              Department.find(dept.id).name 
            }.from("人事部").to("開発部")
          end

          it "部署新規登録ページへリダイレクト" do
            subject
            expect(response).to redirect_to new_department_path
          end
        end

        context "パラメータが不正な場合" do
          subject { patch department_path(dept.id), params: { department: { name: "" } } }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "部署名変更失敗" do
            expect do
              subject
            end.not_to change { 
              Department.find(dept.id).name 
            }
          end

          it "フォームに'field_with_errors'があること" do
            subject
            expect(response.body).to include "field_with_errors"
          end
        end

        context "登録されている部署と同じ部署名の場合" do
          subject { patch department_path(dept.id), params: { department: registered_params } }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "部署名変更失敗" do
            expect do
              subject
            end.not_to change { 
              Department.find(dept.id).name 
            }
          end

          it "フォームに'field_with_errors'があること" do
            subject
            expect(response.body).to include "field_with_errors"
          end
        end

        context "部署IDが正しくない場合" do
          subject { patch department_path(dept.id + sales_dept.id), params: { department: { name: "開発部" } } }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 302
          end

          it "部署新規登録ページへリダイレクト" do
            subject
            expect(response).to redirect_to new_department_path
          end
        end
      end

      context "一般ユーザーの場合" do
        before { sign_in user }
        subject { patch department_path(dept.id), params: { department: { name: "開発部" } } }

        it "リクエスト成功" do
          subject
          expect(response.status).to eq 302
        end

        it "部署名変更失敗" do
          expect do
            subject
          end.not_to change { 
            Department.find(dept.id).name 
          }
        end

        it "root_pathへリダイレクト" do
          subject
          expect(response).to redirect_to root_path
        end
      end
    end

    context "未ログイン" do
      subject { patch department_path(dept.id), params: { department: { name: "開発部" } } }

      it "リクエスト成功" do
        subject
        expect(response.status).to eq 302
      end

      it "部署名更新失敗" do
        expect do
          subject
        end.not_to change { 
          Department.find(dept.id).name 
        }
      end

      it "ログインページへリダイレクト" do
        subject
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  # 部署削除
  describe "DELETE #destroy" do
    let!(:not_set_dept) { create(:not_set_dept) }

    context "ログイン済" do
      context "管理ユーザーの場合" do
        before { sign_in admin_user }

        context "正しい部署IDの場合" do
          subject { delete department_path(dept.id) }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 302
          end

          it "部署削除成功" do
            expect do
              subject
            end.to change { Department.count }.by(-1)
          end

          it "削除した部署に所属するユーザーを未設定に変更" do
            expect do
              subject
            end.to change { 
              User.find(admin_user.id).department_id 
            }.from(dept.id).to(not_set_dept.id)
          end

          it "部署新規登録ページへリダイレクト" do
            subject
            expect(response).to redirect_to new_department_path
          end
        end

        context "存在しない部署IDの場合" do
          subject { delete department_path(dept.id + not_set_dept.id) }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 302
          end

          it "部署削除失敗" do
            expect do
              subject
            end.to change { Department.count }.by(0)
          end

          it "部署新規登録ページへリダイレクト" do
            subject
            expect(response).to redirect_to new_department_path
          end
        end

        context "未設定の部署IDの場合" do
          subject { delete department_path(not_set_dept.id) }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 302
          end

          it "部署削除失敗" do
            expect do
              subject
            end.to change { Department.count }.by(0)
          end

          it "部署新規登録ページへリダイレクト" do
            subject
            expect(response).to redirect_to new_department_path
          end
        end
      end

      context "一般ユーザーの場合" do
        before { sign_in user }
        subject { delete department_path(dept.id) }

        it "リクエスト成功" do
          subject
          expect(response.status).to eq 302
        end

        it "部署削除失敗" do
          expect do
            subject
          end.to change { Department.count }.by(0)
        end

        it "root_pathへリダイレクト" do
          subject
          expect(response).to redirect_to root_path
        end
      end
    end

    context "未ログイン" do
      subject { delete department_path(dept.id) }

      it "リクエスト成功" do
        subject
        expect(response.status).to eq 302
      end

      it "部署削除失敗" do
        expect do
          subject
        end.to change { Department.count }.by(0)
      end

      it "ログインページへリダイレクト" do
        subject
        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end
