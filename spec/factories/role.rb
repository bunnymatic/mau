FactoryGirl.define do
  factory :role do
    role 'a_role'
    trait :admin do
      role 'admin'
    end
  end
end

