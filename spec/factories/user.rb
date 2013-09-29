
FactoryGirl.define do

  sequence(:login) {|n| "whatever#{n}" }
  factory :user do
    login
    email { "#{login}@example.com" }
    password { 'mypass' }
    password_confirmation { 'mypass' }
  end
end
