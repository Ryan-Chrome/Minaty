module SchedulesHelper

    # スケージュールに必要なArrayを生成
    def create_schedule_arrays(schedules, work_time)
        @schedule_times = Array.new
        @schedule_start = Array.new
        @schedule_end = Array.new
        schedules.each do |schedule|
            @schedule_times << (time_exchange(schedule.start_at, work_time)..time_exchange(schedule.finish_at, work_time)-1).to_a
            @schedule_start << time_exchange(schedule.start_at, work_time)
            @schedule_end << time_exchange(schedule.finish_at, work_time) -1
        end
    end

    # other_user用　スケジュールArray生成
    def create_other_schedule_arrays(schedules, work_time)
        @other_user_schedule_times = Array.new
        @other_user_schedule_start = Array.new
        @other_user_schedule_end = Array.new
        schedules.each do |schedule|
            @other_user_schedule_times << (time_exchange(schedule.start_at, work_time)..time_exchange(schedule.finish_at, work_time)-1).to_a
            @other_user_schedule_start << time_exchange(schedule.start_at, work_time)
            @other_user_schedule_end << time_exchange(schedule.finish_at, work_time)-1
        end
    end

    # スケージュールの番号付与
    def time_exchange(input, work_time)
        hours = work_time
        time = input.delete("^0-9")
        hours_time = time[0..1]
        minutes_time = time[2]
        s = 0
        hours.each do |n|
            if n.to_s.length == 1
                if "0" + n.to_s == hours_time
                    @change_number = s + minutes_time.to_i
                    break
                end
            else
                if n == hours_time.to_i
                    @change_number = s + minutes_time.to_i
                    break
                end
            end
            s += 6
        end
        return @change_number
    end

    # スケジュールのhours抜き取り
    def hours_time_change(input)
        time = input.delete("^0-9")
        hours_time = time[0..1].to_i
    end

    #スケジュールパラメータチェック
    def schedule_hours_params_check(hours)
        times = (0..24).to_a
        times.map!{|n| n.to_s}
        times.map! do |n|
            next n if n.length == 2
            "0" + n
        end
        times.include?(hours)
    end

    def schedule_minutes_params_check(minutes)
        times = (0..5).to_a
        times.map!{|n| n.to_s}
        times.map!{|n| n + "0"}
        times.include?(minutes)
    end

    # 円グラフ用スケジュールオブジェクト生成
    def total_schedule_circle(user, objs)
        schedule_list = Array.new
        objs.each do |obj|
            target_objs = user.schedules.where(
                name: obj.name
            )
            work_time = 0
            target_objs.each do |t|
                start_time = Time.parse(t.start_at)
                end_time = Time.parse(t.finish_at)
                work = (end_time - start_time)/3600
                work_time += work
            end
            schedule_list << [obj.name, work_time]
        end
        schedule_list.sort! {|a,b| a[1] <=> b[1]}
        schedule_list.reverse!
        return schedule_list
    end

    def month_schedule_circle(user, objs, beginning, the_end)
        schedule_list = Array.new
        objs.each do |obj|
            target_objs = user.schedules.where(
                "work_on >= ? AND work_on <= ? AND name = ?",
                beginning,
                the_end,
                obj.name
            )
            work_time = 0
            target_objs.each do |t|
                start_time = Time.parse(t.start_at)
                end_time = Time.parse(t.finish_at)
                work = (end_time - start_time)/3600
                work_time += work
            end
            schedule_list << [obj.name, work_time]
        end
        schedule_list.sort! {|a,b| a[1] <=> b[1]}
        schedule_list.reverse!
        return schedule_list
    end

    def week_schedule_circle(user, objs, beginning, the_end)
        schedule_list = Array.new
        objs.each do |obj|
            target_objs = user.schedules.where(
                "work_on >= ? AND work_on <= ? AND name = ?",
                beginning,
                the_end,
                obj.name
            )
            work_time = 0
            target_objs.each do |t|
                start_time = Time.parse(t.start_at)
                end_time = Time.parse(t.finish_at)
                work = (end_time - start_time)/3600
                work_time += work
            end
            schedule_list << [obj.name, work_time]
        end
        schedule_list.sort! {|a,b| a[1] <=> b[1]}
        schedule_list.reverse!
        return schedule_list
    end

    # 円グラフ用パーセントオブジェクト生成
    def create_schedule_parsent(array, work_time)
        parsents = Array.new
        total_parsent = 0
        array.each do |obj|
            parsents << [obj[0], (
                ((obj[1] + total_parsent) * 100 / work_time)
            ).floor.to_s + "%"]
            total_parsent += obj[1]
        end
        return parsents
    end
end
