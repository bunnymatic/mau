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
    starttime { Time.zone.now + 24.hours }
    endtime { Time.zone.now + 25.hours }
    reception_starttime { Time.zone.now + 24.hours }
    url { Faker::Internet.url }
  end
end
