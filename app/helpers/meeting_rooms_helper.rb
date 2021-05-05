module MeetingRoomsHelper

    #スケジュールパラメータチェック
    def hours_check(hours)
        times = (0..24).to_a
        times.map!{|n| n.to_s}
        times.map! do |n|
            next n if n.length == 2
            "0" + n
        end
        times.include?(hours)
    end

    def minutes_check(minutes)
        times = (0..5).to_a
        times.map!{|n| n.to_s}
        times.map!{|n| n + "0"}
        times.include?(minutes)
    end

end
