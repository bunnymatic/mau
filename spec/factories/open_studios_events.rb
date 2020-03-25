# frozen_string_literal: true

FactoryBot.define do
  factory :open_studios_event do
    start_date { Time.zone.now }
    end_date { start_date + 1.day }
    start_time { 'noon' }
    end_time { '6p' }
    key { start_date.strftime('%Y%m') }
    promote { true }
    trait :future do
      start_date { Time.zone.now + 1.week }
    end
    trait :past do
      start_date { Time.zone.now - 6.months }
    end
  end
end
