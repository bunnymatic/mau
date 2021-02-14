FactoryBot.define do
  factory :blacklist_domain do
    domain { Faker::Internet.domain_name }
  end
end
