# encoding: utf-8
require "rails_helper"

RSpec.describe "UserAuthentications", type: :request do
  let!(:dept) { create(:human_resources_dept) }
  let!(:admin_user) { create(:admin_user, department_id: dept.id) }
  let!(:other_user) { create(:other_user, department_id: dept.id) }

  let(:valid_params) { attributes_for(:user, department_id: dept.id) }
  let(:invalid_name_params) { attributes_for(:user, name: "", department_id: dept.id) }
  let(:invalid_kana_params) { attributes_for(:user, kana: "", department_id: dept.id) }
  let(:invalid_email_params) { attributes_for(:user, email: "", department_id: dept.id) }
  let(:invalid_dept_params) { attributes_for(:user, department_id: "") }
  let(:invalid_password_params) { attributes_for(:user, password: "", department_id: dept.id) }
  let(:invalid_password_confirmation_params) {
    attributes_for(:user, password_confirmation: "", department_id: dept.id)
  }
  let(:invalid_double_password_params) {
    attributes_for(:user, password_confirmation: "", password: "", department_id: dept.id)
  }

  # ユーザー新規作成フォーム
  describe "GET #new" do
    subject { get new_user_registration_path }

    context "ログイン済" do
      context "管理ユーザーの場合" do
        before { sign_in admin_user }

        it "リクエスト成功" do
          subject
          expect(response.status).to eq 200
        end

        it "新規ユーザー作成フォーム表示" do
          subject
          expect(response.body).to include "新規ユーザー作成"
        end
      end

      context "一般ユーザーの場合" do
        before { sign_in other_user }

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

  # ユーザー新規作成
  describe "POST #create" do
    context "ログイン済" do
      context "管理ユーザーの場合" do
        before { sign_in admin_user }

        context "パラメータが正の場合" do
          subject {
            post user_registration_path,
                 params: { user: valid_params }
          }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 302
          end

          it "ユーザー作成成功" do
            expect do
              subject
            end.to change { User.count }.by(1)
          end

          it "ユーザー管理画面にリダイレクト" do
            subject
            expect(response).to redirect_to users_path
          end
        end

        context "パラメータが不正な場合" do
          context "パラメータに名前が含まれていない場合" do
            subject {
              post user_registration_path,
                   params: { user: invalid_name_params }
            }

            it "リクエスト成功" do
              subject
              expect(response.status).to eq 200
            end

            it "ユーザー作成失敗" do
              expect do
                subject
              end.to change { User.count }.by(0)
            end

            it "ユーザー管理画面にリダイレクトされないこと" do
              subject
              expect(response).not_to redirect_to users_path
            end
          end

          context "パラメータにフリガナが含まれていない場合" do
            subject {
              post user_registration_path,
                   params: { user: invalid_kana_params }
            }

            it "リクエスト成功" do
              subject
              expect(response.status).to eq 200
            end

            it "ユーザー作成失敗" do
              expect do
                subject
              end.to change { User.count }.by(0)
            end

            it "ユーザー管理画面にリダイレクトされないこと" do
              subject
              expect(response).not_to redirect_to users_path
            end
          end

          context "パラメータにメールアドレスが含まれていない場合" do
            subject {
              post user_registration_path,
                   params: { user: invalid_email_params }
            }

            it "リクエスト成功" do
              subject
              expect(response.status).to eq 200
            end

            it "ユーザー作成失敗" do
              expect do
                subject
              end.to change { User.count }.by(0)
            end

            it "ユーザー管理画面にリダイレクトされないこと" do
              subject
              expect(response).not_to redirect_to users_path
            end
          end

          context "パラメータに部署IDが含まれていない場合" do
            subject {
              post user_registration_path,
                   params: { user: invalid_dept_params }
            }

            it "リクエスト成功" do
              subject
              expect(response.status).to eq 200
            end

            it "ユーザー作成失敗" do
              expect do
                subject
              end.to change { User.count }.by(0)
            end

            it "ユーザー管理画面にリダイレクトされないこと" do
              subject
              expect(response).not_to redirect_to users_path
            end
          end

          context "パラメータにパスワードが含まれていない場合" do
            subject {
              post user_registration_path,
                   params: { user: invalid_password_params }
            }

            it "リクエスト成功" do
              subject
              expect(response.status).to eq 200
            end

            it "ユーザー作成失敗" do
              expect do
                subject
              end.to change { User.count }.by(0)
            end

            it "ユーザー管理画面にリダイレクトされないこと" do
              subject
              expect(response).not_to redirect_to users_path
            end
          end

          context "パラメータに確認パスワードが含まれていない場合" do
            subject {
              post user_registration_path,
                   params: { user: invalid_password_confirmation_params }
            }

            it "リクエスト成功" do
              subject
              expect(response.status).to eq 200
            end

            it "ユーザー作成失敗" do
              expect do
                subject
              end.to change { User.count }.by(0)
            end

            it "ユーザー管理画面にリダイレクトされないこと" do
              subject
              expect(response).not_to redirect_to users_path
            end
          end
        end
      end

      context "一般ユーザーの場合" do
        before { sign_in other_user }
        subject {
          post user_registration_path,
               params: { user: valid_params }
        }

        it "リクエスト成功" do
          subject
          expect(response.status).to eq 302
        end

        it "ユーザー作成失敗" do
          expect do
            subject
          end.to change { User.count }.by(0)
        end

        it "root_pathへリダイレクト" do
          subject
          expect(response).to redirect_to root_path
        end
      end
    end

    context "未ログイン" do
      subject {
        post user_registration_path,
             params: { user: valid_params }
      }

      it "リクエスト成功" do
        subject
        expect(response.status).to eq 302
      end

      it "ユーザー作成失敗" do
        expect do
          subject
        end.to change { User.count }.by(0)
      end

      it "ログインページへリダイレクト" do
        subject
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  # ユーザー編集フォーム
  describe "GET #edit" do
    context "ログイン済" do
      context "管理ユーザーの場合" do
        before { sign_in admin_user }

        context "パラメータが正の場合" do
          subject { get edit_other_user_registration_path(other_user.public_uid) }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 200
          end

          it "ユーザー編集画面表示されること" do
            subject
            expect(response.body).to include "ユーザー編集"
          end
        end

        context "パラメータに存在しないユーザーIDが含まれる場合" do
          subject { get edit_other_user_registration_path("invalid_id") }

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
        before { sign_in other_user }
        subject { get edit_other_user_registration_path(other_user.public_uid) }

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
      subject { get edit_other_user_registration_path(other_user.public_uid) }

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

  # ユーザー編集
  describe "PUT #update" do
    context "ログイン済" do
      context "管理ユーザーの場合" do
        before { sign_in admin_user }

        context "パラメータが正の場合" do
          context "パラメータが全て正常" do
            before {
              valid_params[:current_password] = admin_user.password
            }

            subject {
              patch other_user_registration_path(other_user.public_uid),
                    params: { user: valid_params }
            }

            it "リクエスト成功" do
              subject
              expect(response.status).to eq 302
            end

            it "ユーザー情報編集成功" do
              expect do
                subject
              end.to change {
                User.find(other_user.id).name
              }.from(other_user.name).to valid_params[:name]
            end

            it "ダッシュボードへリダイレクト" do
              subject
              expect(response).to redirect_to user_path(other_user.public_uid)
            end
          end

          context "パラメータにパスワードと確認パスワードが含まれていない場合" do
            before {
              invalid_double_password_params[:current_password] = admin_user.password
            }

            subject {
              patch other_user_registration_path(other_user.public_uid),
                    params: { user: invalid_double_password_params }
            }

            it "リクエスト成功" do
              subject
              expect(response.status).to eq 302
            end

            it "ユーザー情報編集成功" do
              expect do
                subject
              end.to change {
                User.find(other_user.id).name
              }.from(other_user.name).to valid_params[:name]
            end

            it "ダッシュボードへリダイレクト" do
              subject
              expect(response).to redirect_to user_path(other_user.public_uid)
            end
          end
        end

        context "パラメータが不正な場合" do
          context "パラメータに名前が含まれていない場合" do
            before {
              invalid_name_params[:current_password] = admin_user.password
            }

            subject {
              patch other_user_registration_path(other_user.public_uid),
                    params: { user: invalid_name_params }
            }

            it "リクエスト成功" do
              subject
              expect(response.status).to eq 200
            end

            it "ユーザー情報編集失敗" do
              expect do
                subject
              end.not_to change {
                User.find(other_user.id).kana
              }
            end

            it "ダッシュボードにリダイレクトされないこと" do
              subject
              expect(response).not_to redirect_to user_path(other_user.public_uid)
            end
          end

          context "パラメータにフリガナが含まれていない場合" do
            before {
              invalid_kana_params[:current_password] = admin_user.password
            }

            subject {
              patch other_user_registration_path(other_user.public_uid),
                    params: { user: invalid_kana_params }
            }

            it "リクエスト成功" do
              subject
              expect(response.status).to eq 200
            end

            it "ユーザー情報編集失敗" do
              expect do
                subject
              end.not_to change {
                User.find(other_user.id).name
              }
            end

            it "ダッシュボードにリダイレクトされないこと" do
              subject
              expect(response).not_to redirect_to user_path(other_user.public_uid)
            end
          end

          context "パラメータに部署IDが含まれていない場合" do
            before {
              invalid_dept_params[:current_password] = admin_user.password
            }

            subject {
              patch other_user_registration_path(other_user.public_uid),
                    params: { user: invalid_dept_params }
            }

            it "リクエスト成功" do
              subject
              expect(response.status).to eq 200
            end

            it "ユーザー情報編集失敗" do
              expect do
                subject
              end.not_to change {
                User.find(other_user.id).name
              }
            end

            it "ダッシュボードにリダイレクトされないこと" do
              subject
              expect(response).not_to redirect_to user_path(other_user.public_uid)
            end
          end

          context "パラメータにメールアドレスが含まれていない場合" do
            before {
              invalid_email_params[:current_password] = admin_user.password
            }

            subject {
              patch other_user_registration_path(other_user.public_uid),
                    params: { user: invalid_email_params }
            }

            it "リクエスト成功" do
              subject
              expect(response.status).to eq 200
            end

            it "ユーザー情報編集失敗" do
              expect do
                subject
              end.not_to change {
                User.find(other_user.id).name
              }
            end

            it "ダッシュボードにリダイレクトされないこと" do
              subject
              expect(response).not_to redirect_to user_path(other_user.public_uid)
            end
          end

          context "パラメータにパスワードが含まれていない場合" do
            before {
              invalid_password_params[:current_password] = admin_user.password
            }

            subject {
              patch other_user_registration_path(other_user.public_uid),
                    params: { user: invalid_password_params }
            }

            it "リクエスト成功" do
              subject
              expect(response.status).to eq 200
            end

            it "ユーザー情報編集失敗" do
              expect do
                subject
              end.not_to change {
                User.find(other_user.id).name
              }
            end

            it "ダッシュボードにリダイレクトされないこと" do
              subject
              expect(response).not_to redirect_to user_path(other_user.public_uid)
            end
          end

          context "パラメータに確認パスワードが含まれていない場合" do
            before {
              invalid_password_confirmation_params[:current_password] = admin_user.password
            }

            subject {
              patch other_user_registration_path(other_user.public_uid),
                    params: { user: invalid_password_confirmation_params }
            }

            it "リクエスト成功" do
              subject
              expect(response.status).to eq 200
            end

            it "ユーザー情報編集失敗" do
              expect do
                subject
              end.not_to change {
                User.find(other_user.id).name
              }
            end

            it "ダッシュボードにリダイレクトされないこと" do
              subject
              expect(response).not_to redirect_to user_path(other_user.public_uid)
            end
          end

          context "パラメータに管理者パスワードが含まれない場合" do
            subject {
              patch other_user_registration_path(other_user.public_uid),
                    params: { user: valid_params }
            }

            it "リクエスト成功" do
              subject
              expect(response.status).to eq 200
            end

            it "ユーザー情報編集失敗" do
              expect do
                subject
              end.not_to change {
                User.find(other_user.id).name
              }
            end

            it "ダッシュボードにリダイレクトされないこと" do
              subject
              expect(response).not_to redirect_to user_path(other_user.public_uid)
            end
          end

          context "パラメータの管理者パスワードに自分以外のパスワードが含まれる場合" do
            before {
              valid_params[:current_password] = other_user.password
            }

            subject {
              patch other_user_registration_path(other_user.public_uid),
                    params: { user: valid_params }
            }

            it "リクエスト成功" do
              subject
              expect(response.status).to eq 200
            end

            it "ユーザー情報編集失敗" do
              expect do
                subject
              end.not_to change {
                User.find(other_user.id).name
              }
            end

            it "ダッシュボードにリダイレクトされないこと" do
              subject
              expect(response).not_to redirect_to user_path(other_user.public_uid)
            end
          end
        end
      end

      context "一般ユーザーの場合" do
        before { sign_in other_user }

        context "管理者パスワードにログインしているユーザーのパスワードが含まれている場合" do
          before { valid_params[:current_password] = other_user.password }

          subject {
            patch other_user_registration_path(admin_user.public_uid),
                  params: { user: valid_params }
          }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 302
          end

          it "ユーザー情報編集失敗" do
            expect do
              subject
            end.not_to change {
              User.find(admin_user.id).name
            }
          end

          it "root_pathへリダイレクト" do
            subject
            expect(response).to redirect_to root_path
          end
        end

        context "管理者パスワードに管理ユーザーのバスワードが含まれている場合" do
          before { valid_params[:current_password] = admin_user.password }

          subject {
            patch other_user_registration_path(admin_user.public_uid),
                  params: { user: valid_params }
          }

          it "リクエスト成功" do
            subject
            expect(response.status).to eq 302
          end

          it "ユーザー情報編集失敗" do
            expect do
              subject
            end.not_to change {
              User.find(admin_user.id).name
            }
          end

          it "root_pathへリダイレクト" do
            subject
            expect(response).to redirect_to root_path
          end
        end
      end
    end

    context "未ログイン" do
      before { valid_params[:current_password] = admin_user.password }

      subject {
        patch other_user_registration_path(admin_user.public_uid),
              params: { user: valid_params }
      }

      it "リクエスト成功" do
        subject
        expect(response.status).to eq 302
      end

      it "ユーザー情報編集失敗" do
        expect do
          subject
        end.not_to change {
          User.find(admin_user.id).name
        }
      end

      it "ログインページへリダイレクト" do
        subject
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  # ユーザー削除
  describe "DELETE #destroy" do
    let!(:admin_user2) { create(:admin_user2, department_id: dept.id) }

    context "ログイン済" do
      context "管理ユーザーの場合" do
        before { sign_in admin_user }

        context "パラメータが正の場合" do
          context "他のユーザーを削除した場合" do
            subject {
              delete destroy_other_user_registration_path(other_user.public_uid),
                     params: { current_password: admin_user.password }
            }

            it "リクエスト成功" do
              subject
              expect(response.status).to eq 302
            end

            it "ユーザー削除成功" do
              expect do
                subject
              end.to change { User.count }.by(-1)
            end

            it "ユーザー管理画面へリダイレクト" do
              subject
              expect(response).to redirect_to users_path
            end
          end

          context "自分自身を削除した場合" do
            subject {
              delete destroy_other_user_registration_path(admin_user.public_uid),
                     params: { current_password: admin_user.password }
            }

            it "リクエスト成功" do
              subject
              expect(response.status).to eq 302
            end

            it "ユーザー削除成功" do
              expect do
                subject
              end.to change { User.count }.by(-1)
            end

            it "ログインページへリダイレクト" do
              subject
              expect(response).to redirect_to new_user_session_path
            end
          end
        end

        context "パラメータが不正な場合" do
          context "パラメータの管理者パスワードが空の場合" do
            subject {
              delete destroy_other_user_registration_path(other_user.public_uid),
                     params: { current_password: "" }
            }

            it "リクエスト成功" do
              subject
              expect(response.status).to eq 200
            end

            it "ユーザー削除失敗" do
              expect do
                subject
              end.to change { User.count }.by(0)
            end

            it "ユーザー管理画面へリダイレクトされないこと" do
              subject
              expect(response).not_to redirect_to users_path
            end
          end

          context "パラメータの管理者パスワードが一般ユーザーのパスワードの場合" do
            subject {
              delete destroy_other_user_registration_path(other_user.public_uid),
                     params: { current_password: other_user.password }
            }

            it "リクエスト成功" do
              subject
              expect(response.status).to eq 200
            end

            it "ユーザー削除失敗" do
              expect do
                subject
              end.to change { User.count }.by(0)
            end

            it "ユーザー管理画面へリダイレクトされないこと" do
              subject
              expect(response).not_to redirect_to users_path
            end
          end

          context "パラメータの管理者パスワードが他の管理者パスワードの場合" do
            subject {
              delete destroy_other_user_registration_path(other_user.public_uid),
                     params: { current_password: admin_user2.password }
            }

            it "リクエスト成功" do
              subject
              expect(response.status).to eq 200
            end

            it "ユーザー削除失敗" do
              expect do
                subject
              end.to change { User.count }.by(0)
            end

            it "ユーザー管理画面へリダイレクトされないこと" do
              subject
              expect(response).not_to redirect_to users_path
            end
          end

          context "パラメータのユーザーIDが存在しないユーザーIDの場合" do
            subject {
              delete destroy_other_user_registration_path("invalid_user_id"),
                     params: { current_password: admin_user.password }
            }

            it "リクエスト成功" do
              subject
              expect(response.status).to eq 302
            end

            it "ユーザー削除失敗" do
              expect do
                subject
              end.to change { User.count }.by(0)
            end

            it "root_pathへリダイレクト" do
              subject
              expect(response).to redirect_to root_path
            end
          end
        end
      end

      context "一般ユーザーの場合" do
        before { sign_in other_user }

        subject {
          delete destroy_other_user_registration_path(other_user.public_uid),
                 params: { current_password: admin_user.password }
        }

        it "リクエスト成功" do
          subject
          expect(response.status).to eq 302
        end

        it "ユーザー削除失敗" do
          expect do
            subject
          end.to change { User.count }.by(0)
        end

        it "root_pathへリダイレクト" do
          subject
          expect(response).to redirect_to root_path
        end
      end
    end

    context "未ログイン" do
      subject {
        delete destroy_other_user_registration_path(other_user.public_uid),
               params: { current_password: admin_user.password }
      }

      it "リクエスト成功" do
        subject
        expect(response.status).to eq 302
      end

      it "ユーザー削除失敗" do
        expect do
          subject
        end.to change { User.count }.by(0)
      end

      it "ログインページへリダイレクト" do
        subject
        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end
