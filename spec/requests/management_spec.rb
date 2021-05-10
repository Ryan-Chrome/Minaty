require 'rails_helper'

RSpec.describe "Management", type: :request do

    let!(:user){ create(:user) }
    let!(:admin_user){ create(:admin_user) }
    
    # 管理ユーザーは全てのユーザーのダッシュボードにアクセス可
    it "admin_user accesses dashboard (success)" do
        sign_in admin_user
        get management_path(user.public_uid)
        expect(response).not_to redirect_to root_path
    end

    # 一般ユーザーは自分のダッシュボード以外アクセス不可
    it "general_user accesses dashboard (redirect)" do
        sign_in user
        get management_path(admin_user.public_uid)
        expect(response).to redirect_to root_path

        get management_path(user.public_uid)
        expect(response).not_to redirect_to root_path
    end

end