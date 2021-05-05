FactoryBot.define do
  factory :paid_holiday, class: PaidHoliday do
    holiday_on { Date.today }
    reason { "MyText" }
  end
end
