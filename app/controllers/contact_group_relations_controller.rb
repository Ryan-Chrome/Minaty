class ContactGroupRelationsController < ApplicationController

  # ログインユーザー以外のアクセス拒否
  before_action :authenticate_user!

  # ルートパス以外からのアクセス拒否
  before_action :root_path_limits

  def create # format :js && ajax only
    # ユーザーが持つグループと対象グループ取得
    @groups = current_user.contact_groups.includes(:users)
    @contact_group = @groups.find { |obj| obj.id == params[:contact_group_relation][:contact_group_id].to_i }
    # 対象ユーザー取得
    @other_user = User.find_by(
      public_uid: params[:contact_group_relation][:user_id],
    )
    if @contact_group && @other_user && @other_user != current_user
      # リレーション作成
      begin
        @contact_group.users << @other_user
        @new_group_relation = ContactGroupRelation.new
        # 追加できるグループのリスト作成
        @group_list = []
        @groups.each do |group|
          group_users = group.users
          unless group_users.include?(@other_user)
            @group_list.push([group.name, group.id])
          end
        end
      rescue
        respond_to do |format|
          format.js
        end
      end
    end
  end
end
