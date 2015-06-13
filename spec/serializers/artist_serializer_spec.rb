require 'spec_helper'

describe ArtistSerializer do
  let(:artist) { create :artist }
  subject(:serializer) { ArtistSerializer.new(artist) }

  describe 'to_json' do
    [:password, :crypted_password, :remember_token, :remember_token_expires_at,
     :salt, :mailchimp_subscribed_at, :deleted_at, :activated_at, :created_at,
     :max_pieces, :updated_at, :activation_code, :reset_code].each do |field|
      it "does not include #{field} by default" do
        JSON.parse(serializer.to_json)['artist'].should_not have_key field.to_s
      end
    end
    it "includes firstname" do
      JSON.parse(serializer.to_json)['artist']['firstname'].should eql artist.firstname
    end
    it "includes full name" do
      JSON.parse(serializer.to_json)['artist']['full_name'].should eql artist.full_name
    end
  end
end
