class HomesController < ApplicationController
    def home
        if user_signed_in?
            @users = User.all
            @departments = User.select(:department).distinct
            @department_select_option = Array.new
            @departments.each do |department|
                @department_select_option << [department.department, department.department]
            end
            @contact_groups = current_user.contact_groups
            @new_group = ContactGroup.new
            @new_message = GeneralMessage.new
            @message_ids = current_user.reverse_message_relations.select(:general_message_id).distinct.or(current_user.general_message_relations.select(:general_message_id).distinct)
            @messages = GeneralMessage.where(id: @message_ids).order(created_at: "DESC").page(params[:page]).per(10).reverse
            @page_count = GeneralMessage.where(id: @message_ids).page(params[:page]).per(10).total_pages.to_i
            @timer_on = "on";
        
            if params[:department_name].present? || params[:group_id].present?
                #ホーム、部署&グループリスト項目選択時
                if params[:department_name].present?
                    @assignment_users = User.where(department: params[:department_name])
                elsif params[:group_id].present?
                    @group = current_user.contact_groups.find(params[:group_id])
                    @group_user_relations = @group.contact_group_relations
                end

                respond_to do |format|
                    format.html
                    format.js { render "homes/user_search_section" }
                end
            else

                @schedules = current_user.schedules.where(work_on: Date.today).order(:start_at)
                if @schedules.present?
                    if @schedules.last.finish_at[3] == "0"
                        @work_time = (hours_time_change(@schedules.first.start_at)..hours_time_change(@schedules.last.finish_at))
                    else
                        @work_time = (hours_time_change(@schedules.first.start_at)..hours_time_change(@schedules.last.finish_at) + 1)
                    end
                    @work_length = @work_time.to_a.length
                    create_schedule_arrays(@schedules, @work_time)
                end

            end

        end
    end

    private

end
