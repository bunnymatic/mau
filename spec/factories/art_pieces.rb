# frozen_string_literal: true

FactoryBot.define do
  factory :art_piece do
    title { Faker::Name.initials + ' ' + Faker::BossaNova.song }
    photo_file_name    { 'new-art-piece.jpg' }
    photo_content_type { 'image/jpeg' }
    photo_file_size    { 1234 }
    photo_updated_at   { 1.day.ago }
    dimensions { '10 x 10' }
    year { (Time.zone.now - Random.rand(5).years).year }
    medium
    artist do
      FactoryBot.create(:artist, :active)
    end

    trait :with_tag do
      after(:create) do |art_piece|
        art_piece.update tags: [FactoryBot.create(:art_piece_tag)]
      end
    end

    trait :with_tags do
      after(:create) do |art_piece|
        art_piece.update tags: FactoryBot.create_list(:art_piece_tag, 2)
      end
    end
  end
end
