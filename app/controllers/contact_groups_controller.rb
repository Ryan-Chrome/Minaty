class ContactGroupsController < ApplicationController
    # contact_groupsに関するrouteは全てJSフォーマット以外受け付けない
    #　(routesファイル参照)

    # ログインユーザー以外のアクセス拒否
    before_action :authenticate_user!

    # ルートパス以外からのアクセス拒否
    before_action :root_path_limits

    # コンタクトグループ新規作成
    def create
        add_users = params[:contact_group][:user_ids]
        if add_users.present? && !add_users.include?(current_user.id.to_s)
            add_users.map!{ |user_id| User.find_by(public_uid: user_id) }
            @contact_group = current_user.contact_groups.build(contact_group_params)
            if @contact_group.save
                add_users.map{ |user| @contact_group.contact_group_relations.create(user_id: user.id) }
            end
        end
        respond_to do |format|
            format.js
        end
    end

    # コンタクトグループ削除
    def destroy
        @group = current_user.contact_groups.find_by(id: params[:id])
        if @group
            @group.destroy
        end
        respond_to do |format|
            format.js 
        end
    end

    private

        # グループ名ストロングパラメータ
        def contact_group_params
            params.require(:contact_group).permit(:name)
        end

end
