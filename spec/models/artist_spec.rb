# frozen_string_literal: true
require 'rails_helper'

describe Artist do
  let(:max_pieces) { 10 }
  subject(:artist) { FactoryBot.create(:artist, :active, :with_studio, :with_art, max_pieces: max_pieces, firstname: 'Joe', lastname: 'Blow') }
  let!(:open_studios_event) { FactoryBot.create(:open_studios_event) }
  let(:wayout_artist) { FactoryBot.create(:artist, :active, :out_of_the_mission) }
  let(:nobody) { FactoryBot.create(:artist, :active, :without_address) }
  let(:artist_without_studio) { FactoryBot.create(:artist, :active, :with_art, :in_the_mission) }
  let(:artist_info) { artist.artist_info }
  let(:studio) { artist.studio }
  let!(:open_studios_event) { FactoryBot.create(:open_studios_event) }

  describe '#at_art_piece_limit?' do
    subject { super().at_art_piece_limit? }
    it { should eql false }
  end

  before do
    Rails.cache.clear
    allow(OpenStudiosEventService).to receive(:current).and_return(open_studios_event)
  end

  context 'if max_pieces is nil' do
    let(:max_pieces) { nil }

    describe '#at_art_piece_limit?' do
      subject { super().at_art_piece_limit? }
      it { should eql false }
    end
  end
  context 'make sure our factories work' do
    it 'creates an artist info with each artist' do
      expect do
        FactoryBot.create(:artist, :active)
      end.to change(ArtistInfo, :count).by 1
    end
  end

  describe 'create' do
    describe 'auth helpers' do
      describe 'make activation token ' do
        let(:new_artist) { FactoryBot.create(:artist) }
        let(:token) { new_artist.make_activation_code }
        it 'returns a string greater than 20 chars' do
          expect(token.length).to be > 20
        end
        it 'returns a string with only numbers and letters' do
          expect(token).not_to match(/\W+/)
        end
        it 'when called again returns something different' do
          expect(token).not_to eql(new_artist.make_activation_code)
        end
      end
    end
  end

  describe 'update' do
    it 'should update bio' do
      allow_any_instance_of(ArtistInfo).to receive(:compute_geocode).and_return([40, 120])

      artist.bio = 'stuff'
      artist.artist_info.save!
      a = Artist.find(artist.id)
      expect(a.bio).to eql 'stuff'
    end
  end

  describe 'address methods' do
    before do
      @address_methods = [:address, :full_address]
    end
    describe 'artist info only' do
      it 'delegates address to artist info' do
        expect(artist_without_studio.artist_info.address).to eq artist_without_studio.address
      end
    end
    describe 'studio + artist info' do
      it 'returns studio address' do
        @address_methods.each do |method|
          expect(artist.send(method)).not_to be_nil
          expect(artist.send(method)).to eq artist.studio.send(method)
        end
      end
    end
    describe 'neither address in artist info nor studio' do
      it 'returns empty for address' do
        expect(nobody.send(:address)).to be_empty
      end
      it { expect(nobody).to_not be_address }
    end
  end
  describe 'in_the_mission?' do
    context 'for artist in the mission with no studio' do
      before do
        allow(artist_without_studio.artist_info).to receive(:lat).and_return(37.75)
        allow(artist_without_studio.artist_info).to receive(:lng).and_return(-122.41)
      end
      it 'returns true' do
        expect(artist_without_studio).to be_address
        expect(artist_without_studio).to be_in_the_mission
      end
    end
    context 'for artist in the mission with a studio in the mission' do
      before do
        allow(artist.artist_info).to receive(:lat).and_return(37.75)
        allow(artist.artist_info).to receive(:lng).and_return(-122.41)
        allow(artist.studio).to receive(:lat).and_return(37.75)
        allow(artist.studio).to receive(:lng).and_return(-122.41)
      end
      it 'returns true' do
        expect(artist).to be_address
        expect(artist).to be_in_the_mission
      end
    end
    it 'returns false for artist with wayout address' do
      expect(wayout_artist).to be_address
      expect(wayout_artist).to_not be_in_the_mission
    end
    context 'for artist not in the mission but in a studio in the mission' do
      before do
        studio = FactoryBot.create(:studio)
        wayout_artist.update_attributes studio: studio
        wayout_artist.reload
        allow(wayout_artist.studio).to receive(:lat).and_return(37.75)
        allow(wayout_artist.studio).to receive(:lng).and_return(-122.41)
      end
      it 'returns true' do
        expect(wayout_artist).to be_address
        expect(wayout_artist).to be_in_the_mission
      end
    end
  end
  describe 'get from info' do
    it 'responds to method bio' do
      expect { artist.bio }.not_to raise_error
    end
  end
  describe 'fetch address' do
    context 'without studio association' do
      let(:artist_info) { artist_without_studio.artist_info }

      it 'returns correct street' do
        expect(artist_info.street).to eql artist.street
      end
      it 'returns correct address' do
        expect(artist_without_studio.address.to_s).to include artist.street
      end
      it 'returns correct lat/lng' do
        expect(artist_info.lat).to be
        expect(artist_info.lng).to be
      end
    end
    context 'with studio association' do
      it 'returns correct street' do
        expect(artist.address.street).to eql studio.street
      end
      it 'returns correct address' do
        expect(artist.address.to_s).to eql studio.address.to_s
      end
      it 'returns correct lat/lng' do
        expect(artist.lat).to be_within(0.001).of(studio.lat)
        expect(artist.lng).to be_within(0.001).of(studio.lng)
      end
    end
  end
  describe 'representative piece' do
    it 'is the first returned by art_pieces' do
      expect(artist.representative_piece).to eql artist.art_pieces[0]
    end
    it 'calls Cache.write if Cache.read returns nil' do
      ap = ArtPiece.find_by(artist_id: artist.id)
      allow(Rails.cache).to receive(:read).and_return(nil)
      expect(Rails.cache).to receive(:write).once
      allow(artist).to receive(:art_pieces).and_return([ap])
      expect(artist.representative_piece).to eql ap
    end
    it 'doesn\'t call Cache.write if Cache.read returns something' do
      allow(Rails.cache).to receive(:read)
        .with(artist.representative_art_cache_key)
        .and_return(artist.art_pieces[0].id)
      expect(Rails.cache).to receive(:write).never
      artist.representative_piece
    end
    it 'doesn\'t call Cache.write if there are no art pieces' do
      allow(Rails.cache).to receive(:read).and_return(nil)
      expect(Rails.cache).to receive(:write).never
      allow(artist).to receive(:art_pieces).and_return([])
      expect(artist.representative_piece).to eql nil
    end
  end

  describe 'representative piece' do
    it 'is included in the users art pieces' do
      expect(artist.art_pieces).to include artist.representative_piece
    end
    it 'is nil for users with no art pieces' do
      expect(wayout_artist.representative_piece).to be_nil
    end
    it 'is the same as the first piece from art_pieces' do
      expect(artist.representative_piece).to eql artist.art_pieces[0]
    end
  end

  describe 'destroying artists' do
    let(:quentin) { create(:artist, :with_art) }
    let(:art_piece) { quentin.art_pieces.first }
    context 'then artist removes that artpiece' do
      before do
        create_favorite(artist, art_piece)
        create_favorite(artist, quentin)

        # validate fixtures setup
        expect(artist.favorites.map(&:favoritable_id)).to include art_piece.id

        art_piece.destroy
      end
      it 'art_piece is no longer in users favorite list' do
        expect(artist.reload.favorites.map(&:favoritable_id)).to_not include art_piece.id
      end
    end
  end

  describe '#tally_os' do
    before do
      artist
    end
    it 'tallies today\'s os participants' do
      expect { Artist.tally_os }.to change(OpenStudiosTally, :count).by(1)
    end
    it 'only records 1 entry per day' do
      expect do
        2.times { Artist.tally_os }
      end.to change(OpenStudiosTally, :count).by(1)
    end

    it 'updates the record if it runs more than once 1 entry per day' do
      Artist.tally_os
      a = Artist.all.reject(&:doing_open_studios?).first
      t = OpenStudiosTally.last
      a.artist_info.update_os_participation(open_studios_event.key, true)
      a.artist_info.save
      Artist.tally_os
      expect(OpenStudiosTally.last.count).to eql(t.count + 1)
    end
  end

  describe 'doing_open_studios?' do
    before do
      artist_without_studio
      artist.update_os_participation open_studios_event.key, true
    end

    it 'returns true for an artist doing this open studios (with no args)' do
      doing, notdoing = Artist.all.partition(&:doing_open_studios?)
      expect(doing.size).to be >= 1
      expect(notdoing.size).to eq(Artist.count - 1)
    end
  end

  describe 'art piece helpers' do
    before do
      artist
    end
    it 'most recent art piece should be the representative' do
      expect(artist.representative_piece.title).to be_present
    end

    it 'returns art_pieces in by created at if there is no order' do
      expect(artist.art_pieces.to_a).to eql artist.art_pieces.sort_by(&:created_at).reverse
    end

    it 'returns art_pieces in by created at, then order if there is order' do
      artist.art_pieces.reverse.each_with_index do |ap, idx|
        ap.update_attributes(position: idx)
      end
      expect(artist.art_pieces.map(&:position)).to be_strictly_decreasing
    end
  end

  describe 'named scopes' do
    before do
      artist
      wayout_artist
    end
    describe '.without_art' do
      it 'does not include fans' do
        artists = Artist.without_art
        expect(artists.map(&:type).uniq).to eql ['Artist']
        expect(artists.map { |a| a.art_pieces.count }.uniq).to eql [0]
      end
    end
    describe '.with_representative_image' do
      it 'returns only artists with a representative image' do
        active = Artist.active
        w_image = Artist.active.with_representative_image.all
        expect(active.count).not_to eql w_image.count
        expect(active.select { |a| a.representative_piece.blank? }.size).to be >= 1
        expect(w_image.select { |a| a.representative_piece.blank? }).to be_empty
      end
    end
    describe '.open_studios_participants' do
      before do
        artist.update_os_participation open_studios_event.key, true
      end

      it 'returns 0 artists for an unknown os' do
        expect(Artist.open_studios_participants('200810').count).to eql 0
      end
      it 'returns 1 artist(s) for the current open studios' do
        artists = Artist.open_studios_participants
        expect(artists.size).to eq(1)
      end
    end
  end
end
