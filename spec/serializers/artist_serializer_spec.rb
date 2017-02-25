# frozen_string_literal: true
require 'rails_helper'

describe ArtistSerializer do
  let(:artist) { create :artist }
  subject(:serializer) { ActiveModelSerializers::SerializableResource.new(artist) }

  describe 'to_json' do
    [:password, :crypted_password, :remember_token, :remember_token_expires_at,
     :salt, :mailchimp_subscribed_at, :deleted_at, :activated_at, :created_at,
     :max_pieces, :updated_at, :activation_code, :reset_code].each do |field|
      it "does not include #{field} by default" do
        expect(JSON.parse(serializer.to_json)['artist']).not_to have_key field.to_s
      end
    end
    it "includes firstname" do
      expect(JSON.parse(serializer.to_json)['artist']['firstname']).to eql artist.firstname
    end
    it "includes full name" do
      expect(JSON.parse(serializer.to_json)['artist']['full_name']).to eql artist.full_name
    end
    it 'includes the street address' do
      expect(JSON.parse(serializer.to_json)['artist']['street_address']).to eql artist.street
    end
    it 'includes the city' do
      expect(JSON.parse(serializer.to_json)['artist']['city']).to eql artist.address.city
    end
    it 'includes a url for the map' do
      expect(JSON.parse(serializer.to_json)['artist']['map_url']).to eql artist.map_link
    end
  end
end
