FactoryGirl.define do

  sequence(:login) {|n| "whatever%08d" % n }
  factory :user do
    login
    email { "#{login}@example.com" }
    password { 'bmatic' }
    password_confirmation { 'bmatic' }
    firstname { Faker::Name.first_name }
    lastname { Faker::Name.first_name }
    profile_image { Faker::Files.file }
    image_height { 2000 + rand(1000) }
    image_width { 2000 + rand(1000) }
    url { Faker::Internet.url }
    trait :pending do
      state :pending
      activation_code 'factory_activation_code'
    end

    trait :active do
      state :active
      activation_code 'factory_activation_code'
    end

    trait :manager do
      after(:create) do |u|
        u.roles << (Role.find_by_role(:manager) || FactoryGirl.create(:role, :role => :manager))
        u.save!
      end
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

  factory :fan, :parent => :user, :class => 'MAUFan' do
    type { 'MAUFan' }
    active
  end


  factory :artist, :parent => :user, :class => 'Artist' do
    type { 'Artist' }

    after(:create) do |artist|
      FactoryGirl.create(:artist_info, :artist => artist)
    end

    ignore do
      number_of_art_pieces 3
    end

    trait :with_no_address do
      after(:create) do |artist|
        artist.artist_info.update_attributes(street: nil, city: nil, addr_state: nil, zip: nil)
      end
    end
    trait :with_tags do
      active
      after(:create) do |artist, ctx|
        artist.update_attributes(tags: FactoryGirl.create_list(:art_piece_tag, 2))
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
        artist.create_studio(FactoryGirl.attributes_for(:studio))
      end
    end

  end

end
