FactoryGirl.define do
  sequence(:subject) { |n| "Subject of Feedback #{n}" }
  factory :feedback do
    subject
    email { Faker::Internet.email }
    login { Faker::Internet.user_name }
    page { %w( this that theother ).sample }
    comment { Faker::Lorem.paragraphs(1) }
    url { Faker::Internet.url }
    skillsets { %w(welding skydiving maintenance basura).sample }
    bugtype { %w(severe stupid whatever).sample }
  end
end
