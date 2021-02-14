FactoryBot.define do
  factory :medium do
    sequence(:name) { |n| "#{Faker::Lorem.word} #{n}" }
  end
end
