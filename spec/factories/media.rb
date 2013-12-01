FactoryGirl.define do
  factory :medium do
    sequence(:name) { "Medium #{n}" }
  end
end
