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

FactoryGirl.define do
  factory :feedback_mail do
    note_type { 'help' }
    email { 'jon@wherever.com' }
    email_confirm { 'jon@wherever.com' }
    feedlink { nil }
    inquiry { Faker::Lorem.paragraphs(1).join }
    operating_system { "MacOSX - Mavericks" }
    browser { "IE7" }
  end
end