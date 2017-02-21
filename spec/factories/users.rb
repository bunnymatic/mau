require_relative '../support/test_users_helper'

FactoryGirl.define do

  sequence(:login) {|n| "#{Faker::Internet.user_name}%04d" % n }
  factory :user do
    login
    email { "#{login}@example.com" }
    password { TestUsersHelper::DEFAULT_PASSWORD }
    password_confirmation { TestUsersHelper::DEFAULT_PASSWORD }
    firstname { Faker::Name.first_name }
    lastname { Faker::Name.first_name }
    nomdeplume { Faker::Company.name }
    profile_image { Faker::Files.file }
    website { Faker::Internet.url }
    trait :pending do
      state :pending
      activation_code 'factory_activation_code'
    end

    trait :active do
      state :active
      activation_code 'factory_activation_code'
      activated_at { Time.zone.now - 1.hour }
    end

    trait :manager do
      after(:create) do |u|
        u.roles << (Role.find_by_role(:manager) || FactoryGirl.create(:role, role: :manager))
        u.save!
      end
    end

    trait :editor do
      after(:create) do |u|
        u.roles << (Role.find_by_role(:editor) || FactoryGirl.create(:role, role: :editor))
        u.save!
      end
    end

    trait :admin do
      after(:create) do |u|
        u.roles << (Role.find_by_role(:admin) || FactoryGirl.create(:role, role: :admin))
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
      FactoryGirl.create(:artist_info, artist: artist, max_pieces: context.max_pieces)
      if context.doing_open_studios
        artist.update_os_participation context.doing_open_studios, true
      end
    end

    transient do
      max_pieces 10
      number_of_art_pieces 3
      doing_open_studios nil
    end

    trait :with_links do
      facebook { Faker::Internet.url }
      twitter { Faker::Internet.url }
      instagram { nil }
    end

    trait :in_the_mission do
      after(:create) do |artist|
        artist.artist_info.update_attributes(street: '1890 bryant st', city: 'sf', addr_state: 'ca', zip: '94110', lat: 37.763232, lng: -122.410636)
      end
    end

    trait :out_of_the_mission do
      after(:create) do |artist|
        artist.artist_info.update_attributes(street: '100 main', city: 'nyc', addr_state: 'ny', zip: '10011', lat: 20, lng: 20)
      end
    end

    trait :without_address do
      after(:create) do |artist|
        artist.artist_info.update_attributes(street: nil, city: nil, addr_state: nil, zip: nil, lat: nil, lng: nil)
      end
    end
    trait :with_tagged_art do
      active
      after(:create) do |artist, ctx|
        FactoryGirl.create_list(:art_piece, ctx.number_of_art_pieces, :with_tag, artist: artist)
      end
    end
    trait :with_art do
      active
      after(:create) do |artist, ctx|
        num = ctx.number_of_art_pieces
        num.times.each do |idx|
          FactoryGirl.create(:art_piece, artist: artist, created_at: idx.weeks.ago)
        end
        artist.reload
      end
    end

    trait :with_studio do
      active
      after(:create) do |artist|
        studio = Studio.first || FactoryGirl.create(:studio)
        artist.update_attribute :studio, studio
      end
    end

  end

end
