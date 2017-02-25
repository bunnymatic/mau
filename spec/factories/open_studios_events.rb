# frozen_string_literal: true
FactoryGirl.define do
  factory :open_studios_event do
    start_date { Time.zone.now }
    end_date { start_date + 1.day }
    key { start_date.strftime("%Y%m") }
    logo_file_name { 'x.png' }
    logo_content_type { 'image/png' }
    logo_file_size { 10 }
    trait :future do
      start_date { Time.zone.now + 1.week }
    end
  end
end
