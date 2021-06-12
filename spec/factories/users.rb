FactoryBot.define do
  factory :user, class: User do
    name { "example" }
    kana { "example" }
    email { "test@email.com" }
    password { "foobar" }
    password_confirmation { "foobar" }
    admin { false }
  end

  factory :other_user, class: User do
    name { "other_user" }
    kana { "other_user" }
    email { "other@email.com" }
    password { "otherfoobar" }
    password_confirmation { "otherfoobar" }
    admin { false }
  end

  factory :therd_user, class: User do
    name { "therd_user" }
    kana { "therd_user" }
    email { "test3@email.com" }
    password { "foobar" }
    password_confirmation { "foobar" }
    admin { false }
  end

  factory :admin_user, class: User do
    name { "admin_user" }
    kana { "admin_kana" }
    email { "admin@email.com" }
    password { "foobar" }
    password_confirmation { "foobar" }
    admin { true }
  end

  factory :sales_user, class: User do
    name { "sales_user" }
    kana { "セールス ユーザー" }
    email { "sales@email.com" }
    password { "foobar" }
    password_confirmation { "foobar" }
    admin { false }
  end

  factory :admin_user2, class: User do
    name { "admin_2" }
    kana { "admin_2" }
    email { "admin2@email.com" }
    password { "admin2foobar" }
    password_confirmation { "admin2foobar" }
    admin { true }
  end
end
