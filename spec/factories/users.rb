FactoryBot.define do
    factory :user, class: User do
        name { "example" }
        kana { "example" }
        email { "test@email.com" }
        department { "人事部" }
        password { "foobar" }
        password_confirmation { "foobar" }
        admin { false }
    end

    factory :other_user , class: User do
        name { "other_user" }
        kana { "other_user" }
        email { "other@email.com" }
        department { "人事部" }
        password { "foobar" }
        password_confirmation { "foobar" }
        admin { false }
    end

    factory :therd_user, class: User do
        name { "therd_user" }
        kana { "therd_user" }
        email { "test3@email.com" }
        department { "人事部" }
        password { "foobar" }
        password_confirmation { "foobar" }
        admin { false }
    end

    factory :admin_user, class: User do
        name { "admin_user" }
        kana { "admin_user" }
        email { "admin@email.com" }
        department { "人事部" }
        password { "foobar" }
        password_confirmation { "foobar" }
        admin { true }
    end

    factory :sales_user, class: User do
        name { "sales_user" }
        kana { "セールス ユーザー" }
        email { "sales@email.com" }
        department { "営業部" }
        password { "foobar" }
        password_confirmation { "foobar" }
        admin { false }
    end

end