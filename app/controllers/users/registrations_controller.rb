# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]
  prepend_before_action :require_no_authentication, :only => [:cancel]
  prepend_before_action :authenticate_scope!, :only => [:destroy, :new, :create, :edit, :update]

  # 管理ユーザー以外はルートへリダイレクト
  before_action :current_user_admin?, only: [:new, :create, :edit, :update, :destroy]

  # 勤怠情報取得
  before_action :get_sidebar_attendance, only: [:new, :edit]

  # GET /resource/sign_up
  def new
    @departments = Department.where.not(name: "未設定")
    @department_select = []
    @departments.each do |department|
      @department_select << [department.name, department.id]
    end
    build_resource
    yield resource if block_given?
    respond_with resource
  end

  # POST /resource
  def create
    @departments = Department.where.not(name: "未設定")
    @department_select = []
    @departments.each do |department|
      @department_select << [department.name, department.id]
    end
    build_resource(sign_up_params)
    resource.save
    yield resource if block_given?
    if resource.persisted?
      set_flash_message! :notice, :signed_up
      redirect_to users_path
    else
      clean_up_passwords resource
      set_minimum_password_length
      render :new
    end
  end

  # GET /resource/edit
  def edit
    @user = User.find_by(public_uid: params[:id])
    if @user.present?
      self.resource = resource_class.to_adapter.get!(@user.id)
      @departments = Department.where.not(name: "未設定")
      @department_select = []
      @departments.each do |department|
        @department_select << [department.name, department.id]
      end
    else
      redirect_to root_path
    end
  end

  # PUT /resource
  def update
    @user = User.find_by(public_uid: params[:id])
    self.resource = resource_class.to_adapter.get!(@user.id)
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)
    resource_updated = update_resource(resource, account_update_params)
    
    if resource_updated
      set_flash_message_for_update(resource, prev_unconfirmed_email)
      bypass_sign_in(current_user) if sign_in_after_change_password?

      respond_with resource, location: after_update_path_for(resource)
    else
      @departments = Department.where.not(name: "未設定")
      @department_select = []
      @departments.each do |department|
        @department_select << [department.name, department.id]
      end
      clean_up_passwords resource
      set_minimum_password_length
      render :edit
    end
  end

  # DELETE /resource
  def destroy
    @user = User.find_by(public_uid: params[:id])
    if @user
      if destroy_admin_password_valid?(params[:current_password])
        @user.destroy
        if current_user == @user
          Devise.sign_out_all_scopes ? sign_out : sign_out(current_user)
          redirect_to new_user_session_path
        else
          redirect_to users_path
        end
      else
        @departments = Department.where.not(name: "未設定")
        @department_select = []
        @departments.each do |department|
          @department_select << [department.name, department.id]
        end
        flash.now[:alert] = "管理者パスワードが不正です"
        render :edit
      end
    else
      redirect_to root_path
    end
  end


  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  protected

    def update_resource(resource, params)
      resource.update_with_admin_password(params, current_user)
    end

    def after_update_path_for(resource)
      user_path(@user.public_uid)
    end

    def destroy_admin_password_valid?(password)
      current_user.valid_admin_user_password?(password)
    end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
