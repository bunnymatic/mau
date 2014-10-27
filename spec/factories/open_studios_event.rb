FactoryGirl.define do
  factory :open_studios_event do
    start_date { Time.zone.now }
    end_date { start_date + 1.day }
    key { start_date.strftime("%Y%m") }
    logo { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/open_studios_event.png'), 'image/png') }

    trait :future do
      start_date { Time.zone.now + 1.week }
    end

  end
end
