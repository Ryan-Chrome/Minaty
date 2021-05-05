require 'rails_helper'

RSpec.describe "ContactGroup", type: :request do

    let!(:user){ create(:user) }
    let!(:other_user){ create(:other_user) }
    let(:header){ { "HTTP_REFERER" => root_url } }
    let(:invalid_header){ { "HTTP_REFERER" =>  meeting_rooms_url} }

    # コンタクトグループ新規作成
    describe "POST #create" do
        let(:contact_group_params){ { "contact_group"=>{"name"=>"テストグループ", "user_ids"=>["#{other_user.public_uid}"]} } }
        let(:invalid_contact_group_params){ { "contact_group"=>{"name"=>"テストグループ"} } }
        # ログイン済みユーザー
        context "user is logged in" do
            before do
                sign_in user
            end

            context "Request" do
                # root_pathからのリクエスト(js形式)成功
                it "Success from root_path" do
                    post contact_groups_path, params: contact_group_params, headers: header, xhr: true
                    expect(response.status).to eq 200
                    expect(response).not_to redirect_to root_path
                end

                # js形式以外のリクエストは例外になること
                it "Error from root_path(html)" do
                    expect do
                        post contact_groups_path, params: contact_group_params, headers: header
                    end.to raise_error(ActionController::RoutingError)
                end

                # root_path以外からのリクエスト(アプリ内)をroot_pathへリダイレクト
                it "Redirect not from root_path" do
                    post contact_groups_path, params: contact_group_params, headers: invalid_header, xhr: true
                    expect(response.status).to eq 200
                    expect(response).to redirect_to root_path
                end
            end

            context "Create" do
                # 有効なパラメータかつ有効なアプリ内ページ(root_path: 成功)
                # contact_group_relationも作成されること
                it "Success valid params and valid header" do
                    expect do
                        post contact_groups_path, params: contact_group_params, headers: header, xhr: true
                    end.to change{ ContactGroup.count }.by(1).and change { ContactGroupRelation.count }.by(1)
                end

                # 無効なパラメータ(失敗)
                it "Error invalid params" do
                    expect do
                        post contact_groups_path, params: invalid_contact_group_params, headers: header, xhr: true
                    end.to change{ ContactGroup.count }.by(0).and change { ContactGroupRelation.count }.by(0)
                end

                # 無効なアプリ内ページ(失敗)
                it "Error invalid header" do
                    expect do
                        post contact_groups_path, params: contact_group_params, headers: invalid_header, xhr: true
                    end.to change{ ContactGroup.count }.by(0).and change { ContactGroupRelation.count }.by(0)
                end
            end

            context "Message" do
                # 成功メッセージが表示されること
                it "Success message" do
                    post contact_groups_path, params: contact_group_params, headers: header, xhr: true
                    expect(response.body).to match("グループを登録しました。")
                end

                # 失敗メッセージが表示されること
                it "Error message" do
                    post contact_groups_path, params: invalid_contact_group_params, headers: header, xhr: true
                    expect(response.body).to match("処理に失敗しました。")
                end
            end
        end

        # 未ログインユーザー
        context "user is not logged in" do
            context "Request" do
                # 認証失敗
                it "Error root_path" do
                    post contact_groups_path, params: contact_group_params, headers: header, xhr: true
                    expect(response.status).to eq 401
                end
            end
        end
    end

    # コンタクトグループ削除
    describe "DELETE #destroy" do
        let!(:contact_group){ user.contact_groups.create(name: "テストグループ") }
        let!(:contact_group_relation){ contact_group.contact_group_relations.create(user_id: other_user.id) }
        let!(:other_user_contact_group){ other_user.contact_groups.create(name: "テストグループ") }
        let!(:other_user_contact_group_relation){ other_user_contact_group.contact_group_relations.create(user_id: user.id) }
        # ログイン済みユーザー
        context "user is logged in" do
            before do
                sign_in user
            end

            context "Request" do
                # root_pathからのリクエスト(js形式)成功
                it "Success from root_path(js)" do
                    delete contact_group_path(contact_group.id), headers: header, xhr: true
                    expect(response.status).to eq 200
                    expect(response).not_to redirect_to root_path
                end

                # js形式以外のリクエストは例外になること
                it "Error from root_path(html)" do
                    expect do
                        delete contact_group_path(contact_group.id), headers: header
                    end.to raise_error(ActionController::RoutingError)
                end

                # root_path以外からのリクエスト(アプリ内)をroot_pathへリダイレクト
                it "Redirect not from root_path" do
                    delete contact_group_path(contact_group.id), headers: invalid_header, xhr: true
                    expect(response.status).to eq 200
                    expect(response).to redirect_to root_path
                end
            end

            context "Destroy" do
                # 存在する自分のグループかつ有効なアプリ内ページ(root_path: 成功)
                # contact_group_relationも削除されること
                it "Success valid contact_group and valid header" do
                    expect do
                        delete contact_group_path(contact_group.id), headers: header, xhr: true
                    end.to change{ ContactGroup.count }.by(-1).and change{ ContactGroupRelation.count }.by(-1)
                end

                # 自分のグループではない場合
                it "Error other_user_contact_group" do
                    expect do
                        delete contact_group_path(other_user_contact_group.id), headers: header, xhr: true
                    end.to change{ ContactGroup.count }.by(0).and change{ ContactGroupRelation.count }.by(0)
                end

                # 無効なアプリ内ページ(失敗)
                it "Error invalid header" do
                    expect do
                        delete contact_group_path(contact_group.id), headers: invalid_header, xhr: true
                    end.to change{ ContactGroup.count }.by(0).and change{ ContactGroupRelation.count }.by(0)
                end
            end

            context "Message" do
                # 成功メッセージが表示されること
                it "Success message" do
                    delete contact_group_path(contact_group.id), headers: header, xhr: true
                    expect(response.body).to match("#{contact_group.name}を削除しました。")
                end

                # エラーメッセージが表示されること
                it "Error message" do
                    delete contact_group_path(other_user_contact_group.id), headers: header, xhr: true
                    expect(response.body).to match("処理に失敗しました。")
                end
            end
        end
    end

end