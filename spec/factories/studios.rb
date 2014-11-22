FactoryGirl.define do
  factory :studio do
    name { "O'R" + Faker::Company.name }
    street { Faker::Address.street_name }
    city { Faker::Address.city }
    state { Faker::Address.state }
    zip { Faker::Address.zip_code }
    lat { 37.75 }
    lng { -122.41 }
    url { Faker::Internet.url }
    profile_image { Faker::Files.file }
    cross_street { Faker::Address.street_name }
    phone { Faker::PhoneNumber.phone_number }

    ignore do
      artist_count 2
    end

    trait :with_artists do
      after(:create) do |studio, context|
        FactoryGirl.create_list :artist, context.artist_count, :active, :studio_id => studio.id
      end
    end
  end
end