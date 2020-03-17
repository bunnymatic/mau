# frozen_string_literal: true

require 'rails_helper'

describe ArtistInfo do
  it_behaves_like AddressMixin

  let!(:open_studios_event) { FactoryBot.create(:open_studios_event) }
  let(:artist_info) { FactoryBot.create(:artist).artist_info }

  describe 'address mixin' do
    it 'responds to address' do
      expect(artist_info).to respond_to :address
    end
    it 'responds to full_address' do
      expect(artist_info).to respond_to :full_address
    end
  end

  describe 'create' do
    describe 'with valid attrs' do
      it 'artist_info is valid' do
        expect(artist_info).to receive(:compute_geocode).and_return([-37, 122])
        expect(artist_info).to be_valid
      end
      it 'save triggers geocode' do
        expect(artist_info).to receive(:compute_geocode).and_return([-37, 122])
        artist_info.save
      end
      it 'requires an artist' do
        expect do
          artist_info.artist_id = nil
          artist_info.save!
        end.to raise_error ActiveRecord::RecordInvalid
      end
    end
  end

  describe 'save' do
    it 'triggers geocode given new street' do
      expect(artist_info).to receive(:compute_geocode).at_least(1).and_return([-37, 122])
      artist_info.save!
    end
  end
end
