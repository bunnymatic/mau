FactoryGirl.define do
  factory :art_piece do
    title { Faker::Company.name }
    filename { Faker::Files.file_with_path }
    artist {
      FactoryGirl.create(:artist,:activated)
    }
    after_build do |art_piece|
      art_piece.medium = FactoryGirl.create(:medium)
    end
  end
end
