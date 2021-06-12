FactoryBot.define do
  factory :human_resources_dept, class: Department do
    name { "人事部" }
  end

  factory :sales_dept, class: Department do
    name { "営業部" }
  end

  factory :development_dept, class: Department do
    name { "開発部" }
  end

  factory :not_set_dept, class: Department do
    name { "未設定" }
  end
end
