FactoryGirl.define do
  factory :artist_info do
    open_studios_participation { '201010' }
    lat { 37.1 }
    lng { -122.0 }
    bio { Faker::Lorem.paragraphs(4).join ' '}
    facebook { 'http://www.facebook.com/' + Faker::Files.dir(1) }
  end
end
