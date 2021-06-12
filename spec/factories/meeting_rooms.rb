FactoryBot.define do
  factory :meeting_room, class: MeetingRoom do
    name { "meeting_room" }
    start_at { "#{Date.today} 0:00:00" }
    finish_at { "#{Date.today} 23:50:00" }
    meeting_date { Date.today }
    room_entry_users { "example" } # バリデーションにかからないようにするため
  end
end
