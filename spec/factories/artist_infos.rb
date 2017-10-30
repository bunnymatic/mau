# frozen_string_literal: true
FactoryBot.define do
  factory :artist_info do
    street { '1890 bryant st' }
    city { 'san francisco' }
    addr_state { 'ca' }
    lat { 37.75 }
    lng { -122.41 }
    bio { Faker::Lorem.paragraphs(1).join ' ' }
    max_pieces { 10 }
  end
end
