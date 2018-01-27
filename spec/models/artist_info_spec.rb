# frozen_string_literal: true
require 'rails_helper'

describe ArtistInfo do
  it_should_behave_like AddressMixin

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

  describe 'open studios participation' do
    before do
      allow(artist_info).to receive(:compute_geocode).at_least(1).and_return([-37, 122])
      artist_info.save!
    end

    describe 'get' do
      it "returns true if participation is 'true'" do
        expect(artist_info).to receive('open_studios_participation').at_least(:once).and_return('date|other')
        expect(artist_info.os_participation['date']).to eq(true)
      end
      it 'returns nil if participation is missing' do
        expect(artist_info).to receive('open_studios_participation').at_least(:once).and_return('date|something')
        expect(artist_info.os_participation['other']).to be_nil
      end
    end

    describe 'add entry' do
      it "adding with = given = { '201104' => true } sets os_participation['201104']" do
        artist_info.send(:os_participation=, '201104' => true)
        artist_info.reload
        expect(artist_info.os_participation['201104']).to eql true
      end
      it "adding with update_os_participation[ '201104', true] sets os_participation['201104']" do
        artist_info.update_os_participation('201104', true)
        artist_info.save
        artist_info.reload
        expect(artist_info.os_participation['201104']).to eql true
      end
    end
    describe 'update' do
      before do
        artist_info.open_studios_participation = '201104'
      end
      it "sets false using = {'201104',false}" do
        artist_info.send(:os_participation=, '201104' => false)
        artist_info.reload
        expect(artist_info.os_participation['201104']).to be_nil
      end
      it "sets false given update('201104',false)" do
        artist_info.update_os_participation('201104', false)
        artist_info.save
        artist_info.reload
        expect(artist_info.os_participation['201104']).to be_nil
      end
      it 'adds another key properly using update' do
        artist_info.update(open_studios_participation: '201104')
        artist_info.update_os_participation('201114', true)
        artist_info.reload
        expect(artist_info.os_participation['201114']).to eq(true)
        expect(artist_info.os_participation['201104']).to eq(true)
      end
      it 'adds another key properly using =' do
        artist_info.update(open_studios_participation: '201104')
        artist_info.send(:os_participation=, '201204' => true)
        artist_info.reload
        expect(artist_info.os_participation['201204']).to eq(true)
        expect(artist_info.os_participation['201104']).to eq(true)
      end
    end
  end
end
