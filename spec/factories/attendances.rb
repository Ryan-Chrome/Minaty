FactoryBot.define do
  factory :attendance, class: Attendance do
    work_on { Date.today }
    arrived_at { DateTime.now }
  end
end
