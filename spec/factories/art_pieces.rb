FactoryBot.define do
  factory :art_piece do
    title { "#{Faker::Name.initials} #{Faker::BossaNova.song}" }
    dimensions { "#{Random.rand(10..50)} x #{Random.rand(10..50)}" }
    year { (Time.zone.now - Random.rand(10).years).year }
    medium
    price { rand(1..1000) + rand.round(2) }
    artist do
      FactoryBot.create(:artist, :active)
    end

    photo { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/art.png'), 'image/png') }
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
