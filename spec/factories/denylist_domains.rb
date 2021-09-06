FactoryBot.define do
  factory :denylist_domain do
    domain { Faker::Internet.domain_name }
  end
end
