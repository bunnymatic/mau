FactoryGirl.define do
  sequence(:title) { |n| "Event title #{n}" }
  factory :event do
    title
    description { Faker::Lorem.paragraphs(1).join }
    tweet { Faker::Lorem.words(10).join(' ') }
    venue { Faker::Company.name }
    street { Faker::Address.street_name }
    city { Faker::Address.city }
    state { Faker::Address.state }
    zip { Faker::Address.zip_code }
    sequence(:starttime) { |n| Time.zone.now + n.days }
    sequence(:endtime) { |n| Time.zone.now + 1.day + n.days }
    url { Faker::Internet.url }

    trait :with_reception do
      sequence(:reception_starttime) { |n| Time.zone.now + n.days + 1.hour }
      sequence(:reception_endtime) { |n| Time.zone.now + n.days + 3.hours }
    end
  end
end
