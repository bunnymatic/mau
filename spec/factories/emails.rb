FactoryGirl.define do
  factory(:email) do
    name { Faker::Name.name }
    email { Faker::Internet.email }
  end
end
