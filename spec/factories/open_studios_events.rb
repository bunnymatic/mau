FactoryBot.define do
  factory :open_studios_event do
    start_date { Time.zone.now }
    end_date { start_date + 1.day }
    start_time { 'noon' }
    end_time { '6p' }
    key { start_date.strftime('%Y%m') }
    promote { true }
    trait :future do
      start_date { 1.week.from_now }
    end
    trait :past do
      start_date { Time.zone.now - 6.months }
    end
    trait :with_current_special_event do
      end_date { start_date + 1.week }
      special_event_start_date { start_date }
      special_event_start_time { '12:01 am' }
      special_event_end_date { special_event_start_date + 1.day }
      special_event_end_time { '11:59 pm' }
    end
    trait :with_special_event do
      end_date { start_date + 1.week }
      special_event_start_date { start_date + 1.day }
      special_event_end_date { special_event_start_date + 1.day }
    end
  end
end
