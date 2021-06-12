# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)


require 'faker'

Department.create!(name: "未設定")

dept1 = Department.create!(name: "人事部")
dept2 = Department.create!(name: "開発部")
dept3 = Department.create!(name: "営業部")


User.create!(
    name: "加藤 斗也",
    kana: "カトウ トウヤ",
    email: "admin@email.com",
    admin: true,
    password: "foobar",
    department: dept1
)

50.times do |n|
    sample_name = Gimei.kanji
    sample_kana = Gimei.katakana
    sample_email = Faker::Internet.email
    User.create!(
        name: sample_name,
        kana: sample_kana,
        email: sample_email,
        password: "foobar",
        department: dept1
    )
end

50.times do |n|
    sample_name = Gimei.kanji
    sample_kana = Gimei.katakana
    sample_email = Faker::Internet.email
    User.create!(
        name: sample_name,
        kana: sample_kana,
        email: sample_email,
        password: "foobar",
        department: dept2
    )
end

50.times do |n|
    sample_name = Gimei.kanji
    sample_kana = Gimei.katakana
    sample_email = Faker::Internet.email
    User.create!(
        name: sample_name,
        kana: sample_kana,
        email: sample_email,
        password: "foobar",
        department: dept3
    )
end
