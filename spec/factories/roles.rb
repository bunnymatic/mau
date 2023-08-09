FactoryBot.define do
  factory :role do
    role { 'a_role' }
    initialize_with { Role.find_or_create_by(role:) }
    trait :admin do
      role { 'admin' }
    end
    trait :editor do
      role { 'editor' }
    end
    trait :manager do
      role { 'manager' }
    end
  end
end
