class DepartmentsController < ApplicationController

  # ログインユーザー以外のアクセス拒否
  before_action :authenticate_user!

  # 管理ユーザー以外はルートへリダイレクト
  before_action :current_user_admin?

  # 勤怠情報取得
  before_action :get_sidebar_attendance, only: [:new, :edit]

  def new
    @departments = Department.where.not(name: "未設定")
    @new_department = Department.new
  end

  def create 
    # 部署作成
    @new_department = Department.new(department_params)
    if @new_department.save
      redirect_to new_department_path
    else
      @departments = Department.where.not(name: "未設定")
      render "new"
    end
  end

  def edit
    @department = Department.find_by(id: params[:id])
    unless @department
      redirect_to new_department_path
    end
  end

  def update
    @department = Department.find_by(id: params[:id])
    if @department
      # 部署変更
      if @department.update(department_params)
        redirect_to new_department_path
      else
        render "edit"
      end
    else
      redirect_to new_department_path
    end
  end

  def destroy
    department = Department.find_by(id: params[:id])
    not_set_department = Department.find_by(name: "未設定")
    if department && department.name != not_set_department.name
      users = department.users
      # 所属しているユーザーを未設定に変更
      users.each do |user|
        user.update(department_id: not_set_department.id)
      end
      # 部署削除
      department.destroy
    end
    redirect_to new_department_path
  end

  private

  def department_params
    params.require(:department).permit(:name)
  end
end
