FactoryGirl.define do
  factory :studio do
    name { Faker::Company.name }
    street { Faker::Address.street_name }
    city { Faker::Address.city }
    state { Faker::Address.state }
    zip { Faker::Address.zip_code }
    url { Faker::Internet.url }
    profile_image { Faker::Files.file }
    cross_street { Faker::Address.street_name }
    phone { Faker::PhoneNumber.phone_number }
  end
end
