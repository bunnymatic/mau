FactoryGirl.define do
  factory :art_piece do
    title { Faker::Company.name }
    filename { Faker::Files.file_with_path }
    dimensions { '10 x 10' }
    image_height { 1000 }
    image_width { 400 }
    year { (Time.zone.now - Random.rand(5).years).year }
    artist {
      FactoryGirl.create(:artist,:activated)
    }
    after_build do |art_piece|
      art_piece.medium = FactoryGirl.create(:medium)
    end
  end
end
