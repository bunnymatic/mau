FactoryBot.define do
  factory :notification do
    sequence(:message) { Faker::Lorem.words(number: 10).join(' ') }

    trait :active do
      activated_at { Time.zone.yesterday }
    end
  end
end
