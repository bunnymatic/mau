# frozen_string_literal: true
FactoryBot.define do
  factory :application_event do
    message { Faker::Lorem.words(5).join(' ') }
  end

  factory :open_studios_signup_event, parent: :application_event, class: 'OpenStudiosSignupEvent'
  factory :generic_event, parent: :application_event, class: 'GenericEvent'
end
