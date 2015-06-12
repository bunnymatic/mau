require 'spec_helper'

describe ArtistSerializer do
  let(:artist) { create :artist }
  subject(:serializer) { ArtistSerializer.new(artist) }

  describe 'to_json' do
    [:password, :crypted_password, :remember_token, :remember_token_expires_at,
     :salt, :mailchimp_subscribed_at, :deleted_at, :activated_at, :created_at,
     :max_pieces, :updated_at, :activation_code, :reset_code].each do |field|
      it "does not include #{field} by default" do
        JSON.parse(artist.to_json)['artist'].should_not have_key field.to_s
      end
    end
    it "includes firstname" do
      JSON.parse(artist.to_json)['artist']['firstname'].should eql artist.firstname
    end
    it 'includes created_at if we except other fields' do
      a = JSON.parse(artist.to_json(except: :firstname))
      a['artist'].should have_key 'created_at'
      a['artist'].should_not have_key 'firstname'
    end
    it 'includes the artist info if we ask for it' do
      a = JSON.parse(artist.to_json(include: :artist_info))
      a['artist']['artist_info'].should be_a_kind_of Hash
    end
  end
end
