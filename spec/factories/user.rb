FactoryGirl.define do

  sequence(:login) {|n| "whatever#{n}" }
  factory :user do
    login
    email { "#{login}@example.com" }
    password { 'mypass' }
    password_confirmation { 'mypass' }
    firstname { Faker::Name.first_name }
    lastname { Faker::Name.first_name }
    nomdeplume{ Faker::Name.name }
    profile_image { Faker::Files.file_with_path }
    image_height { 2000 + rand(1000) }
    image_width { 2000 + rand(1000) }
  end

  factory :artist do
    type { 'Artist' }
    login
    email { "#{login}@example.com" }
    password { 'mypass' }
    password_confirmation { 'mypass' }
    firstname { Faker::Name.first_name }
    lastname { Faker::Name.last_name }
    nomdeplume{ Faker::Name.name }
    profile_image { Faker::Files.file_with_path }
    image_height { 2000 + rand(1000) }
    image_width { 2000 + rand(1000) }

    after_build do |artist|
      artist_info(:artist => artist)
    end
    trait :activated do
      state :active
    end

  end

end
