# frozen_string_literal: true

require 'rails_helper'

describe Artist do
  let(:max_pieces) { 10 }
  subject(:artist) { FactoryBot.create(:artist, :active, :with_studio, :with_art, max_pieces: max_pieces, firstname: 'Joe', lastname: 'Blow') }
  let!(:open_studios_event) { FactoryBot.create(:open_studios_event) }
  let!(:past_open_studios_event) { FactoryBot.create(:open_studios_event, :past) }
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
      @address_methods = %i[address full_address]
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
      it { expect(nobody.address).to be_empty }
    end
  end
  describe 'in_the_mission?' do
    context 'for artist in the mission with no studio' do
      before do
        allow(artist_without_studio.artist_info).to receive(:lat).and_return(37.75)
        allow(artist_without_studio.artist_info).to receive(:lng).and_return(-122.41)
      end
      it 'returns true' do
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
        expect(artist).to be_in_the_mission
      end
    end
    it 'returns false for artist with wayout address' do
      expect(wayout_artist.address).to be_present
      expect(wayout_artist).to_not be_in_the_mission
    end
    context 'for artist not in the mission but in a studio in the mission' do
      before do
        studio = FactoryBot.create(:studio)
        # don't update lat in factory because `compute_geocode` takes over
        studio.update(lat: 37.75, lng: -122.41)
        wayout_artist.update studio: studio
        wayout_artist.reload
      end
      it 'returns true' do
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
        expect(artist_info.street).to eql artist_without_studio.address.street
      end
      it 'returns correct address' do
        expect(artist_without_studio.address.to_s).to include artist_without_studio.address.street
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
        expect(artist.address.lat).to be_within(0.001).of(studio.lat)
        expect(artist.address.lng).to be_within(0.001).of(studio.lng)
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

  describe 'doing_open_studios?' do
    let(:past_artist) { create(:artist) }
    before do
      artist.open_studios_events << open_studios_event
      past_artist.open_studios_events << past_open_studios_event
      artist_without_studio
    end

    it 'returns true for an artist doing this open studios (with no args)' do
      doing, notdoing = Artist.all.partition(&:doing_open_studios?)
      expect(doing).to eq([artist])
      expect(notdoing.size).to eq(2)
    end

    it 'returns true for an artist doing this a past open studios' do
      doing, notdoing = Artist.all.partition { |artist| artist.doing_open_studios?(past_open_studios_event.key) }
      expect(doing).to eq([past_artist])
      expect(notdoing.size).to eq(2)
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
        ap.update(position: idx)
      end
      expect(artist.art_pieces.map(&:position)).to be_strictly_decreasing
    end
  end

  describe 'named scopes' do
    before do
      artist
      wayout_artist
      create(:artist, studio_id: 10_000_000)
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
        expect(active.count { |a| a.representative_piece.blank? }).to be >= 1
        expect(w_image.select { |a| a.representative_piece.blank? }).to be_empty
      end
    end
    describe '.in_a_group_studio' do
      it 'returns only artists with a valid studio' do
        expect(Artist.in_a_group_studio).to match_array [artist]
      end
    end
    describe '.independent_studio' do
      it 'returns only artists with a valid studio' do
        expect(Artist.independent_studio).to match_array [wayout_artist]
      end
    end
  end
end
