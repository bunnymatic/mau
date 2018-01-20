# frozen_string_literal: true

FactoryBot.define do
  factory(:artist_feed) do
    feed { Faker::Internet.url }
    url { Faker::Internet.url }

    trait :active do
      active { true }
    end
  end
end
