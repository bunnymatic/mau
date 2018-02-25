# frozen_string_literal: true

require 'rails_helper'
describe UpdateArtistService do
  let(:params) { {} }
  let(:artist) { create(:artist) }
  subject(:service) { described_class.new(artist, params) }

  include MockSearchService

  describe '.update' do
    before do
      stub_search_service!
    end

    describe 'without an artist' do
      it 'raises an error' do
        expect { described_class.new(nil, params) }.to raise_error UpdateArtistService::Error
      end
    end

    describe 'with a fan' do
      it 'raises an error' do
        expect { described_class.new(MauFan.new, params) }.to raise_error UpdateArtistService::Error
      end
    end

    describe 'with user attributes' do
      let(:params) do
        { firstname: 'BillyBob' }
      end
      it 'updates them' do
        service.update
        expect(artist.reload.firstname).to eql 'BillyBob'
      end

      it 'registers the change by adding a UserChangeEvent' do
        expect(UserChangedEvent).to receive(:create)
        service.update
      end
    end

    describe 'with artist info attributes' do
      let(:params) do
        { artist_info_attributes: { studionumber: '5' } }
      end
      it 'updates them' do
        service.update
        expect(artist.reload.studionumber).to eql '5'
      end
      it 'does not change the other artist info properties' do
        bio = artist.artist_info.bio
        info_id = artist.artist_info.id
        expect(bio).to be_present
        service.update
        expect(artist.reload.studionumber).to eql '5'
        expect(artist.artist_info.id).to eql info_id
      end
    end

    describe 'with a huge bio update' do
      let(:big_bio) { Faker::Lorem.paragraphs(4).join }
      let(:params) do
        { artist_info_attributes: { bio: big_bio } }
      end
      it 'updates things without raising an error' do
        service.update
      end
    end

    describe 'when the login changes' do
      let(:params) do
        { login: 'newlogin' }
      end
      it 'updates the slug' do
        expect(artist.login).not_to eql 'newlogin'
        expect(artist.slug).not_to eql 'newlogin'
        service.update
        artist.reload
        expect(artist.slug).to eql 'newlogin'
        expect(artist.login).to eql 'newlogin'
      end
    end
  end
end
