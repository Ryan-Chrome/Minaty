class ContactGroupsController < ApplicationController

  # ログインユーザー以外のアクセス拒否
  before_action :authenticate_user!

  # ルートパス以外からのアクセス拒否
  before_action :root_path_limits

  def create # format :js && ajax only
    add_users_id = params[:contact_group][:user_ids]
    if add_users_id.present?
      # グループに追加するユーザー取得
      add_users = User.where(
        public_uid: add_users_id,
      ).where.not(
        public_uid: current_user.public_uid,
      )
      if add_users.present?
        # グループ作成
        @contact_group = current_user.contact_groups.build(
          contact_group_params
        )
        if @contact_group.save
          # リレーション作成
          date = DateTime.now
          add_users_params = add_users.map do |user|
            {
              user_id: user.id,
              contact_group_id: @contact_group.id,
              created_at: date,
              updated_at: date,
            }
          end
          # リレーション作成で例外が出た場合グループ削除
          begin
            ContactGroupRelation.insert_all!(add_users_params)
          rescue
            @contact_group.destroy
          end
        end
      end
    end
  end

  def destroy # fomat :js && ajax only
    @group = current_user.contact_groups.find_by(id: params[:id])
    if @group
      @group.destroy
    end
  end

  private

  # グループ名ストロングパラメータ
  def contact_group_params
    params.require(:contact_group).permit(:name)
  end
end
