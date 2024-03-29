require_relative '../support/test_users_helper'

FactoryBot.define do
  sequence(:login) { |n| sprintf("#{Faker::Internet.user_name}%04d.login", n) }
  factory :user do
    login
    email { "#{login}@example.com" }
    password { TestUsersHelper::DEFAULT_PASSWORD }
    password_confirmation { TestUsersHelper::DEFAULT_PASSWORD }
    firstname { Faker::Name.first_name.delete("'") }
    lastname { Faker::Name.last_name.delete("'") }
    nomdeplume { Faker::Company.name.delete("'") } # apostrophe's mess up Cucumber tests/finders
    website { Faker::Internet.url }
    trait :pending do
      state { :pending }
      activation_code { 'factory_activation_code' }
    end

    trait :deleted do
      state { :deleted }
    end

    trait :suspended do
      state { :suspended }
    end

    trait :with_phone do
      phone { "(415) 555 #{Array.new(4) { rand(10) }.join}" }
    end

    trait :with_photo do
      photo { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/user.png'), 'image/png') }
    end

    trait :active do
      state { :active }
      activation_code { 'factory_activation_code' }
      activated_at { 1.hour.ago }
    end

    trait :manager do
      after(:create) do |u|
        u.roles << (Role.find_by(role: :manager) || FactoryBot.create(:role, role: :manager))
        u.save!
      end
    end

    trait :editor do
      after(:create) do |u|
        u.roles << (Role.find_by(role: :editor) || FactoryBot.create(:role, role: :editor))
        u.save!
      end
    end

    trait :admin do
      after(:create) do |u|
        u.roles << (Role.find_by(role: :admin) || FactoryBot.create(:role, role: :admin))
        u.save!
      end
    end
  end

  factory :mau_fan, parent: :user, class: 'MauFan', aliases: [:fan] do
    type { 'MauFan' }
    active
  end

  factory :artist, parent: :user, class: 'Artist' do
    type { 'Artist' }

    after(:create) do |artist, context|
      FactoryBot.create(:artist_info, artist:, max_pieces: context.max_pieces)
      artist.open_studios_events << OpenStudiosEventService.current if context.doing_open_studios
    end

    transient do
      max_pieces { 10 }
      number_of_art_pieces { 1 }
      doing_open_studios { nil }
    end

    trait :with_links do
      facebook { Faker::Internet.url }
      twitter { Faker::Internet.url }
      instagram { nil }
    end

    trait :in_the_mission do
      after(:create) do |artist|
        artist.artist_info.assign_attributes(
          street: '1890 bryant st',
          city: 'sf',
          addr_state: 'ca',
          zipcode: '94110',
          lat: 37.763232,
          lng: -122.410636,
        )
        artist.artist_info.save(validate: false)
      end
    end

    trait :out_of_the_mission do
      after(:create) do |artist|
        artist.artist_info.assign_attributes(
          street: '100 main',
          city: 'nyc',
          addr_state: 'ny',
          zipcode: '10011',
          lat: 20,
          lng: 20,
        )
        artist.artist_info.save(validate: false)
      end
    end

    trait :without_address do
      after(:create) do |artist|
        artist.artist_info.update(street: nil, city: nil, addr_state: nil, zipcode: nil, lat: nil, lng: nil)
      end
    end
    trait :with_tagged_art do
      active
      after(:create) do |artist, ctx|
        FactoryBot.create_list(:art_piece, ctx.number_of_art_pieces, :with_tag, artist:)
      end
    end
    trait :with_art do
      active
      after(:create) do |artist, ctx|
        ctx.number_of_art_pieces.to_i.times.each do |idx|
          FactoryBot.create(:art_piece, artist:, created_at: idx.weeks.ago, updated_at: idx.weeks.ago)
        end
        artist.reload
      end
    end

    trait :with_studio do
      active
      after(:create) do |artist|
        studio = Studio.first || FactoryBot.create(:studio)
        artist.update(studio:)
        artist.update artist_info_attributes: { lat: nil, lng: nil }
      end
    end
  end
end
