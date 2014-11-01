FactoryGirl.define do
  factory :artist_info do
    open_studios_participation { '201010' }
    street { '1890 bryant st' }
    city { 'san francisco' }
    addr_state { 'ca' }
    lat { 37.75 }
    lng { -122.41 }
    bio { Faker::Lorem.paragraphs(4).join ' '}
    max_pieces { 10 }
  end
end
