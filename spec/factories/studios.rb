FactoryBot.define do
  factory :studio do
    sequence(:name) { |n| Faker::Company.name + n.to_s }
    street { Faker::Address.street_name }
    city { Faker::Address.city }
    state { Faker::Address.state }
    zipcode { Faker::Address.zip_code }
    lat { 37.75 }
    lng { -122.41 }
    url { Faker::Internet.url }
    cross_street { Faker::Address.street_name }
    phone { "(415) 555 #{Array.new(4) { rand(10) }.join}" }
    position { Random.rand(200) }
    transient do
      artist_count { 2 }
    end
    photo { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/profile.png'), 'image/png') }

    trait :with_artists do
      after(:create) do |studio, context|
        create_list :artist, context.artist_count, :active, studio:
      end
    end
  end
end
