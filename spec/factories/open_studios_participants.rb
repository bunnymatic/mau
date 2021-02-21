FactoryBot.define do
  factory :open_studios_participant do
    user
    open_studios_event

    shop_url { Faker::Internet.url }
    video_conference_url { Faker::Internet.url }
    show_email { [true, false].sample }
    show_phone_number { [true, false].sample }
  end
end
