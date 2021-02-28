FactoryBot.define do
  factory :open_studios_participant do
    user
    open_studios_event

    shop_url { Faker::Internet.url }
    video_conference_url { Faker::Internet.url }
    youtube_url { 'http://m.youtube.com/watch?v=abcdefg' }
    show_email { [true, false].sample }
    show_phone_number { [true, false].sample }
  end
end
