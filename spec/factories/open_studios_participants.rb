FactoryBot.define do
  factory :open_studios_participant do
    user
    open_studios_event

    shop_url { Faker::Internet.url }
    video_conference_url { Faker::Internet.url }
    youtube_url { 'http://m.youtube.com/watch?v=abcdefg' }
    show_email { [true, false].sample }
    show_phone_number { [true, false].sample }

    trait :with_conference_schedule do
      open_studios_event { build(:open_studios_event, :with_special_event) }
      after(:create) do |participant, _context|
        schedule = participant.open_studios_event.special_event_time_slots.index_with do |_timeslot|
          true
        end
        participant.video_conference_schedule = schedule
      end
    end
  end
end
