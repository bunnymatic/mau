FactoryGirl.define do
  factory(:thing_with_address) do
    street { Faker::Address.street_name }
    city { Faker::Address.city }
    state { Faker::Address.state }
    zip { Faker::Address.zip_code }
    lat { rand(180) - 90 }
    lng { rand(360) - 180 }
  end
end
