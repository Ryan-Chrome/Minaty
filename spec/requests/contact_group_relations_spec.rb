require 'rails_helper'

RSpec.describe "ContactGroupRelation", type: :request do

    let!(:user){ create(:user) }
    let!(:other_user){ create(:other_user) }
    let!(:therd_user){ create(:therd_user) }
    let!(:contact_group){ user.contact_groups.create(name: "テストグループ") }
    let!(:other_contact_group){ other_user.contact_groups.create(name: "テストグループ") }
    let(:header){ { "HTTP_REFERER" => root_url } }
    let(:invalid_header){ { "HTTP_REFERER" =>  meeting_rooms_url} }

    # コンタクトグループリレーション新規作成フォーム表示
    describe "GET #new" do
        # ログイン済みユーザー
        context "user is logged in" do
            before do
                sign_in user
            end

            context "Request" do
                # root_pathからのリクエスト(js形式)成功
                it "Success from root_path(js)" do
                    get new_contact_group_relation_path, params: { add_user: other_user.public_uid }, headers: header, xhr: true
                    expect(response.status).to eq 200
                    expect(response.body).to match("modal.insertAdjacentHTML")
                    expect(response).not_to redirect_to root_path
                end

                # js形式以外のリクエストは例外になること
                it "Error from root_path(html)" do
                    expect do
                        get new_contact_group_relation_path, params: { add_user: other_user.public_uid }, headers: header
                    end.to raise_error(ActionController::RoutingError)
                end

                # root_path以外からのリクエスト(アプリ内)をroot_pathへリダイレクト
                it "Redirect not from root_path" do
                    get new_contact_group_relation_path, params: { add_user: other_user.public_uid }, headers: invalid_header, xhr: true
                    expect(response.status).to eq 302
                    expect(response).to redirect_to root_path
                end
            end
        end

        # 未ログインユーザー
        context "user is not logged in" do
            context "Request" do
                # 認証失敗すること
                it "Authentication error" do
                    get new_contact_group_relation_path, params: { add_user: other_user.public_uid }, headers: header, xhr: true
                    expect(response.status).to eq 401
                end
            end
        end
    end

    # コンタクトグループリレーション新規作成
    describe "POST #create" do
        let!(:contact_group_relation){ contact_group.contact_group_relations.create(user_id: therd_user.id) }
        # 既に登録されているリレーションのパラメータ
        let(:registered_contact_group_relation_params){ { "contact_group_relation"=>{"contact_group_id"=>"#{contact_group.id}", "user_id"=>"#{therd_user.public_uid}"} } }
        # 他人のグループIDが含まれるパラメータ
        let(:other_contact_group_relation_params){ { "contact_group_relation"=>{"contact_group_id"=>"#{other_contact_group.id}", "user_id"=>"#{therd_user.public_uid}"} } }
        # 自分のユーザーIDが含まれるパラメータ
        let(:current_user_contact_group_relation_params){ { "contact_group_relation"=>{"contact_group_id"=>"#{contact_group.id}", "user_id"=>"#{user.public_uid}"} } }
        # 有効なパラメータ
        let(:contact_group_relation_params){ { "contact_group_relation"=>{"contact_group_id"=>"#{contact_group.id}", "user_id"=>"#{other_user.public_uid}"} } }
        # ログイン済みユーザー
        context "user is logged in" do
            before do
                sign_in user
            end

            context "Request" do
                # root_pathからのリクエスト(js形式)成功
                it "Success from root_path(js)" do
                    post contact_group_relations_path, params: contact_group_relation_params, headers: header, xhr: true
                    expect(response.status).to eq 200
                    expect(response).not_to redirect_to root_path
                end

                # js形式以外のリクエストは例外になること
                it "Error from root_path(html)" do
                    expect do
                        post contact_group_relations_path, params: contact_group_relation_params, headers: header
                    end.to raise_error(ActionController::RoutingError)
                end

                # root_path以外からのリクエスト(アプリ内)をroot_pathへリダイレクト
                it "Redirect not from root_path" do
                    post contact_group_relations_path, params: contact_group_relation_params, headers: invalid_header, xhr: true
                    expect(response.status).to eq 200
                    expect(response).to redirect_to root_path
                end
            end

            context "Create" do
                # 有効なパラメータかつ有効なアプリ内ページ(root_path: 成功)
                it "Success valid params and valid header" do
                    expect do
                        post contact_group_relations_path, params: contact_group_relation_params, headers: header, xhr: true
                    end.to change{ ContactGroupRelation.count }.by(1)
                end

                # 登録済みのリレーションの場合(失敗)
                it "Error invalid params(Registered relation)" do
                    expect do
                        post contact_group_relations_path, params: registered_contact_group_relation_params, headers: header, xhr: true
                    end.to change{ ContactGroupRelation.count }.by(0)
                end

                # 他人のグループIDがパラメータに含まれた場合(失敗)
                it "Error invalid params(other_group)" do
                    expect do
                        post contact_group_relations_path, params: other_contact_group_relation_params, headers: header, xhr: true
                    end.to change{ ContactGroupRelation.count }.by(0)
                end

                # パラメータに自分のIDが含まれていた場合(失敗)
                it "Error invalid params(current_user)" do
                    expect do
                        post contact_group_relations_path, params: current_user_contact_group_relation_params, headers: header, xhr: true
                    end.to change{ ContactGroupRelation.count }.by(0)
                end

                # 無効なアプリ内ページ(失敗)
                it "Error invalid header" do
                    expect do
                        post contact_group_relations_path, params: contact_group_relation_params, headers: invalid_header, xhr: true
                    end.to change{ ContactGroupRelation.count }.by(0)
                end
            end

            context "Message" do
                # 成功メッセージが表示されること
                it "Success message" do
                    post contact_group_relations_path, params: contact_group_relation_params, headers: header, xhr: true
                    expect(response.body).to match("グループに追加しました。")
                end

                # エラーメッセージが表示されること
                it "Error message" do
                    post contact_group_relations_path, params: other_contact_group_relation_params, headers: header, xhr: true
                    expect(response.body).to match("処理に失敗しました。")
                end
            end
        end
    end

end