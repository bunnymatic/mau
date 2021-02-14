FactoryBot.define do
  factory :scammer do
    email { Faker::Internet.email }
    name { Faker::Name.name }
    sequence(:faso_id) { |n| n }
  end
end
