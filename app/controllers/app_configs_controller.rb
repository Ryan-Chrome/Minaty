class AppConfigsController < ApplicationController

	# ログインユーザー以外のアクセス拒否
	before_action :authenticate_user!

	# 管理ユーザー以外はリダイレクト
	before_action :current_user_admin?

	def index
		
	end
end
