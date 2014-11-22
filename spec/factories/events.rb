FactoryGirl.define do
  sequence(:title) { |n| "Event title #{n}" }
  factory :event do
    title
    created_at { Time.zone.now }
    updated_at { Time.zone.now }
    description { Faker::Lorem.paragraphs(1).join }
    tweet { Faker::Lorem.words(10).join(' ') }
    venue { Faker::Company.name }
    street { Faker::Address.street_name }
    city { Faker::Address.city }
    state { Faker::Address.state }
    zip { Faker::Address.zip_code }
    sequence(:starttime) { |n| Time.zone.now + n.days }
    endtime { starttime + 2.days }
    url { Faker::Internet.url }

    trait :published do
      published_at { Time.zone.now }
    end
    trait :with_reception do
      sequence(:reception_starttime) { |n| Time.zone.now + n.days + 1.hour }
      sequence(:reception_endtime) { |n| Time.zone.now + n.days + 3.hours }
    end
  end
end