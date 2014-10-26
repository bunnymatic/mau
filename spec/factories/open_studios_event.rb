FactoryGirl.define do
  factory :open_studios_event do
    start_date { Time.zone.now }
    end_date { start_date + 1.day }
    key { start_date.strftime("%Y%m") }
  end
end
