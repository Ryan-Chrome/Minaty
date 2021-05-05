# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)


require 'faker'

User.create!(
    name: "加藤 斗也",
    kana: "カトウ トウヤ",
    email: "admin@email.com",
    assignment: "人事部",
    admin: true,
    password: "foobar"
)

50.times do |n|
    sample_name = Gimei.kanji
    sample_kana = Gimei.katakana
    sample_email = Faker::Internet.email
    User.create!(
        name: sample_name,
        kana: sample_kana,
        email: sample_email,
        assignment: "人事部",
        password: "foobar"
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
        assignment: "開発部",
        password: "foobar"
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
        assignment: "営業部",
        password: "foobar"
    )
end
