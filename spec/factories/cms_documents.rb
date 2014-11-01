FactoryGirl.define do
  factory :cms_document do
    page { Faker::Files.dir }
    section { Faker::Files.dir }
    article { Faker::Lorem.paragraphs(2).join }
  end
end
