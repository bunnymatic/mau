# frozen_string_literal: true

FactoryBot.define do
  sequence(:subject) { |n| "Subject of Feedback #{n}" }
  factory :feedback do
    subject
    email { Faker::Internet.email }
    login { Faker::Internet.user_name }
    page { %w[this that theother].sample }
    comment { Faker::Lorem.paragraphs(number: 1).join }
    url { Faker::Internet.url }
    skillsets { %w[welding skydiving maintenance basura].sample }
    bugtype { %w[severe stupid whatever].sample }
  end
end

FactoryBot.define do
  factory :feedback_mail do
    note_type { 'help' }
    email { 'jon@wherever.com' }
    email_confirm { 'jon@wherever.com' }
    inquiry { Faker::Lorem.paragraphs(number: 1).join }
    operating_system { 'MacOSX - Mavericks' }
    browser { 'IE7' }
    device { 'unk' }
  end
end
