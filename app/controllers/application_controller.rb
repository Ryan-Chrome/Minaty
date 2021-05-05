class ApplicationController < ActionController::Base
    include ApplicationHelper
    include SchedulesHelper
    include MeetingRoomsHelper

    before_action :config_permitted_parameters, if: :devise_controller?
    before_action :get_sidebar_attendance


    def config_permitted_parameters
        devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :kana, :department, :admin])
        devise_parameter_sanitizer.permit(:account_update, keys: [:name, :kana, :department, :admin])
    end

    def root_path_limits
        if request.referer != root_url
            respond_to do |format|
                format.any { redirect_to root_path }
            end
        end
    end

    def current_user_admin?
        unless current_user.admin?
          redirect_to root_path
        end
    end
    
    def get_sidebar_attendance
        if user_signed_in?
            @paid_holiday = current_user.paid_holidays.find_by(
                holiday_on: Date.today
            )
            unless @paid_holiday.present?
                @sidebar_attendance = current_user.attendances.find_by(
                    work_on: Date.today
                )
            end 
        end
    end
end
