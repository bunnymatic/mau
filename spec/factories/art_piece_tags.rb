FactoryBot.define do
  factory :art_piece_tag do
    sequence(:name) { |n| "#{Faker::Lorem.word}-#{n}" }
  end
end
