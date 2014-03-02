FactoryGirl.define do

  sequence(:login) {|n| "whatever%08d" % n }
  factory :user do
    login
    email { "#{login}@example.com" }
    password { 'bmatic' }
    password_confirmation { 'bmatic' }
    firstname { Faker::Name.first_name }
    lastname { Faker::Name.first_name }
    nomdeplume{ Faker::Name.name }
    profile_image { Faker::Files.file_with_path }
    image_height { 2000 + rand(1000) }
    image_width { 2000 + rand(1000) }
    trait :pending do
      state :pending
      activation_code 'factory_activation_code'
    end

    trait :active do
      state :active
      activation_code 'factory_activation_code'
    end

    trait :editor do
      after(:create) do |u|
        u.roles << (Role.find_by_role(:editor) || FactoryGirl.create(:role, :role => :editor))
        u.save!
      end
    end

    trait :admin do
      after(:create) do |u|
        u.roles << (Role.find_by_role(:admin) || FactoryGirl.create(:role, :role => :admin))
        u.save!
      end
    end

  end

  factory :artist do
    type { 'Artist' }
    login
    email { "#{login}@example.com" }
    password { 'bmatic' }
    password_confirmation { 'bmatic' }
    firstname { Faker::Name.first_name }
    lastname { Faker::Name.last_name }
    nomdeplume{ Faker::Name.name }
    profile_image { Faker::Files.file_with_path }
    image_height { 2000 + rand(1000) }
    image_width { 2000 + rand(1000) }

    after(:create) do |artist|
      FactoryGirl.create(:artist_info, :artist => artist)
      artist.reload
    end

    ignore do
      number_of_art_pieces 3
    end

    trait :editor do
      after(:create) do |u|
        u.roles << (Role.find_by_role(:editor) || FactoryGirl.create(:role, :role => :editor))
        u.save!
      end
    end

    trait :admin do
      after(:create) do |u|
        u.roles << (Role.find_by_role(:admin) || FactoryGirl.create(:role, :role => :admin))
        u.save!
      end
    end

    trait :pending do
      state :pending
      activation_code 'factory_activation_code'
    end

    trait :active do
      state :active
      activation_code 'factory_activation_code'
    end

    trait :with_art do
      active
      after(:create) do |artist, ctx|
        FactoryGirl.create_list(:art_piece, ctx.number_of_art_pieces, :artist => artist)
        artist.reload
      end
    end

    trait :with_studio do
      after(:build) do |artist|
        artist.build_studio(FactoryGirl.attributes_for(:studio))
      end
    end

  end

end
