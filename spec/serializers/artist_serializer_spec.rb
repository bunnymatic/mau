# frozen_string_literal: true

require 'rails_helper'

describe ArtistSerializer do
  let(:artist) { create :artist }
  subject(:serializer) { ActiveModelSerializers::SerializableResource.new(artist) }

  describe 'to_json' do
    it 'does not include several fields by default' do
      %i[password crypted_password remember_token remember_token_expires_at
         salt mailchimp_subscribed_at deleted_at activated_at created_at
         max_pieces updated_at activation_code reset_code].each do |field|
        expect(JSON.parse(serializer.to_json)['artist']).not_to have_key field.to_s
      end
    end
    it 'includes a bunch of default attributes' do
      expect(JSON.parse(serializer.to_json)['artist']['firstname']).to eql artist.firstname
      expect(JSON.parse(serializer.to_json)['artist']['full_name']).to eql artist.full_name
      expect(JSON.parse(serializer.to_json)['artist']['street_address']).to eql artist.street
      expect(JSON.parse(serializer.to_json)['artist']['city']).to eql artist.address.city
      expect(JSON.parse(serializer.to_json)['artist']['map_url']).to eql artist.map_link
    end
  end
end
