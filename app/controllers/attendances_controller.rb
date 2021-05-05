class AttendancesController < ApplicationController

    # ログインユーザー以外のアクセス禁止
    before_action :authenticate_user!

    def create
        @sidebar_attendance = current_user.attendances.create(
            work_on: Date.today,
            arrived_at: DateTime.now
        )
        if @sidebar_attendance.valid?
            respond_to do |format|
                format.js
            end
        else
            redirect_to root_path
        end
    end

    def update
        @sidebar_attendance = current_user.attendances.find_by(id: params[:id])
        if @sidebar_attendance.present? && !@sidebar_attendance.left_at.present?
            @sidebar_attendance.update(
                left_at: DateTime.now
            )
            if @sidebar_attendance.valid?
                respond_to do |format|
                    format.js
                end
            else
                redirect_to root_path
            end
        else
            redirect_to root_path
        end
    end

end
