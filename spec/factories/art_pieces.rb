# frozen_string_literal: true
FactoryGirl.define do
  factory :art_piece do
    title { Faker::Company.name }
    photo_file_name    'new-art-piece.jpg'
    photo_content_type 'image/jpeg'
    photo_file_size    1234
    photo_updated_at   1.day.ago
    dimensions { '10 x 10' }
    year { (Time.zone.now - Random.rand(5).years).year }
    artist do
      FactoryGirl.create(:artist, :active)
    end
    after(:build) do |art_piece|
      art_piece.medium = FactoryGirl.create(:medium)
    end

    trait :with_tag do
      after(:create) do |art_piece|
        art_piece.update_attributes tags: [FactoryGirl.create(:art_piece_tag)]
      end
    end

    trait :with_tags do
      after(:create) do |art_piece|
        art_piece.update_attributes tags: FactoryGirl.create_list(:art_piece_tag, 2)
      end
    end
  end
end
