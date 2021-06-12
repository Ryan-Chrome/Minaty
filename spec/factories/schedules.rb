FactoryBot.define do
  factory :schedule, class: Schedule do
    name { "example" }
    start_at { "12:00" }
    finish_at { "13:00" }
    work_on { Date.today }
  end

  factory :system_schedule, class: Schedule do
    name { "テスト会議" }
    start_at { "10:00" }
    finish_at { "15:30" }
    work_on { Date.today }
  end
end
