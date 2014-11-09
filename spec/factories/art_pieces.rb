FactoryGirl.define do
  factory :art_piece do
    title { "O'R" + Faker::Company.name }
    filename { Faker::Files.file }
    dimensions { '10 x 10' }
    image_height { 1000 }
    image_width { 400 }
    year { (Time.zone.now - Random.rand(5).years).year }
    artist {
      FactoryGirl.create(:artist,:active)
    }
    after(:build) do |art_piece|
      art_piece.medium = FactoryGirl.create(:medium)
    end

    trait :with_tag do
      after(:create) do |art_piece|
        art_piece.update_attribute :tags, [FactoryGirl.create(:art_piece_tag)]
      end
    end
  end
end
