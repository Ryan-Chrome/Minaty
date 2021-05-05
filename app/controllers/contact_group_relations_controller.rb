class ContactGroupRelationsController < ApplicationController
    # contact_group_relationsに関するrouteは全てJSフォーマット以外受け付けない
    #　(routesファイル参照)

    # ログインユーザー以外のアクセス拒否
    before_action :authenticate_user!

    # ルートパス以外からのアクセス拒否
    before_action :root_path_limits
    
    # コンタクトグループリレーション新規作成フォーム表示
    def new
        @add_user = User.find_by(public_uid: params[:add_user])
        if @add_user && @add_user != current_user
            @new_group_relation = ContactGroupRelation.new
            groups = current_user.contact_groups
            @group_list = []
            groups.map{ |group| @group_list.push([group.name, group.id]) unless group.contact_group_relations.find_by(user_id: @add_user.id) }
        end
        respond_to do |format|
            format.js
        end
    end

    # コンタクトグループリレーション新規作成
    def create
        @contact_group = current_user.contact_groups.find_by(id: params[:contact_group_relation][:contact_group_id])
        @add_user = User.find_by(public_uid: params[:contact_group_relation][:user_id])
        if @contact_group && @add_user && @add_user != current_user
            unless @contact_group.contact_group_relations.find_by(user_id: @add_user.id)
                @contact_group.contact_group_relations.create(user_id: @add_user.id)
                @new_group_relation = ContactGroupRelation.new
                @groups = current_user.contact_groups
                @group_list = []
                @groups.map{ |group| @group_list.push([group.name, group.id]) unless group.contact_group_relations.find_by(user_id: @add_user.id) }
            end
        end
    end

end
