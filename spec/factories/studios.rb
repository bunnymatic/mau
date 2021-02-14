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
    phone { "1 (415) 555 #{Array.new(4) { rand(10) }.join}" }
    photo_file_name    { 'new-studio.jpg' }
    photo_content_type { 'image/jpeg' }
    photo_file_size    { 1234 }
    photo_updated_at   { 1.day.ago }
    position { Random.rand(200) }
    transient do
      artist_count { 2 }
    end

    trait :with_artists do
      after(:create) do |studio, context|
        create_list :artist, context.artist_count, :active, studio: studio
      end
    end
  end
end
