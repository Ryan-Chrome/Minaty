FactoryBot.define do

    factory :meeting_room, class: MeetingRoom do
        name { "meeting_room" }
        start_at { "2021-10-09 10:10:00" }
        finish_at { "2021-10-09 15:30:00" }
        meeting_date { Date.today }
        room_entry_users { "example" } # バリデーションにかからないようにするため
    end

end