FactoryGirl.define do
  factory :art_piece do
    title { Faker::Company.name }
    filename { Faker::Files.file_with_path }
    artist {
      FactoryGirl.create(:artist,:state => :active)
    }
  end
end
