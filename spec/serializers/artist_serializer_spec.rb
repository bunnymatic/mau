require 'rails_helper'

describe ArtistSerializer do
  let(:artist) { create :artist }
  let(:parsed) { serialize(artist, described_class) }
  let(:parsed_artist) { parsed[:data][:attributes] }

  describe 'to_json' do
    it 'does not include several fields by default' do
      %i[password crypted_password remember_token remember_token_expires_at
         salt mailchimp_subscribed_at deleted_at activated_at created_at
         max_pieces updated_at activation_code reset_code].each do |field|
        expect(parsed_artist).not_to have_key field.to_s
      end
    end
    it 'includes a bunch of default attributes' do
      expect(parsed_artist[:firstname]).to eql artist.firstname
      expect(parsed_artist[:full_name]).to eql artist.full_name
      expect(parsed_artist[:street_address]).to eql artist.address.street
      expect(parsed_artist[:city]).to eql artist.address.city
      expect(parsed_artist[:map_url]).to eql artist.map_link
    end
  end
end
