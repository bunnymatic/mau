require 'spec_helper'

describe Artist do

  let(:max_pieces) { 10 }
  subject(:artist) { FactoryGirl.create(:artist, :active, :with_studio, :with_art, max_pieces: max_pieces, firstname: 'Joe', lastname: 'Blow') }
  let!(:open_studios_event) { FactoryGirl.create(:open_studios_event) }
  let(:wayout_artist) { FactoryGirl.create(:artist, :active, :out_of_the_mission) }
  let(:nobody) { FactoryGirl.create(:artist, :active, :with_no_address) }
  let(:artist_without_studio) { FactoryGirl.create(:artist, :active,:with_art) }
  let(:artist_info) { artist.artist_info }
  let!(:open_studios_event) { FactoryGirl.create(:open_studios_event) }

  its(:at_art_piece_limit?) { should eql false }
  context 'if max_pieces is nil' do
    let(:max_pieces) { nil }
    its(:at_art_piece_limit?) { should eql false }
  end
  context 'make sure our factories work' do
    it 'creates an artist info with each artist' do
      expect {
        a = FactoryGirl.create(:artist, :active)
      }.to change(ArtistInfo, :count).by 1
    end
  end

  describe "create" do
    describe 'auth helpers' do
      describe "make activation token " do
        let(:new_artist) { FactoryGirl.create(:artist) }
        let(:token) { new_artist.make_activation_code }
        it "returns a string greater than 20 chars" do
          token.length.should > 20
        end
        it "returns a string with only numbers and letters" do
          token.should_not match /\W+/
        end
        it "when called again returns something different" do
          token.should_not eql(new_artist.make_activation_code)
        end
      end
    end

  end

  describe "update" do
    it "should update bio" do
      allow(ArtistInfo.any_instance).to receive(:compute_geocode).and_return([-40,122])

      artist.bio = 'stuff'
      artist.artist_info.save!
      a = Artist.find(artist.id)
      a.bio.should eql 'stuff'
    end

    it "should update email settings" do
      attr_hash = JSON::parse(artist.email_attrs)
      attr_hash['fromartist'].should eql(true)
      attr_hash['fromall'].should eql(true)
      attr_hash['favorites'] = false
      artist.emailsettings = attr_hash
      artist.save
      artist.reload
      attr_hash = artist.emailsettings
      attr_hash['fromartist'].should eql(true)
      attr_hash['fromall'].should eql(true)
      attr_hash['favorites'].should eql(false)
    end
  end

  describe 'address methods' do
    before do
      @address_methods = [:address, :address_hash, :full_address]
    end
    describe 'artist info only' do
      it "returns artist address" do
        @address_methods.each do |method|
          artist_without_studio.send(method).should_not be_nil
          artist_without_studio.send(method).should eql artist_without_studio.artist_info.send(method)
        end
      end
    end
    describe 'studio + artist info' do
      it "returns studio address" do
        @address_methods.each do |method|
          artist.send(method).should_not be_nil
          artist.send(method).should eql artist.studio.send(method)
        end
      end
    end
    describe 'neither address in artist info nor studio' do
      it "returns empty for address" do
        nobody.send(:address).should be_empty
        hsh = nobody.send(:address_hash)
        hsh[:geocoded].should be_false
        hsh[:parsed][:street].should be_nil
        hsh[:latlng].should eql [nil,nil]
      end
      it { expect(nobody).to_not be_has_address }
    end
  end
  describe 'in_the_mission?' do
    it "returns true for artist in the mission with no studio" do
      expect(artist_without_studio).to have_address
      expect(artist_without_studio).to be_in_the_mission
    end
    it "returns true for artist in the mission with a studio in the mission" do
      expect(artist).to have_address
      expect(artist).to be_in_the_mission
    end
    it "returns false for artist with wayout address" do
      expect(wayout_artist).to have_address
      expect(wayout_artist).to_not be_in_the_mission
    end
    it "returns true for artist with wayout address but studio in the mission" do
      wayout_artist.update_attribute :studio, FactoryGirl.create(:studio)
      expect(wayout_artist).to have_address
      expect(wayout_artist).to be_in_the_mission
    end
  end
  describe 'find by full_name' do
    let!(:full_name) { artist.firstname + ' ' + artist.lastname }
    let(:artists) { Artist.find_by_full_name( full_name ) }
    before do
      artist
    end
    context 'with lowercase name' do
      it { artists.should have(1).artist }
      it { artists.first.should eql artist }
    end
    context 'with capitalized name search' do
      let(:full_name) { "Joe Blow" }
      it { artists.should have(1).artist }
      it { artists.first.should eql artist }
    end
    context 'with mixed case search' do
      let(:full_name) { "Joe blow" }
      it { artists.should have(1).artist }
      it { artists.first.should eql artist }
    end
    context 'with substring' do
      let(:full_name) { "Jo blow" }
      it { artists.should be_empty }
    end
  end
  describe 'get from info' do
    it "responds to method bio" do
      lambda { artist.bio }.should_not raise_error
    end
  end
  describe "fetch address" do
    context "without studio association" do
      let(:artist_info) { artist_without_studio.artist_info }

      it "returns correct street" do
        artist_info.street.should eql artist.street
      end
      it "returns correct address" do
        artist_without_studio.address.should include artist.street
      end
      it "returns correct lat/lng" do
        artist_info.lat.should be
        artist_info.lng.should be
      end
    end
    context 'with studio association' do
      it "returns correct street" do
        artist_info.street.should eql artist.street
      end
      it "returns studio address" do
        artist.address.should eql artist.address
      end
      it "returns correct artist info lat/lng" do
        artist_info.lat.should be_within(0.001).of(artist.lat)
        artist_info.lng.should be_within(0.001).of(artist.lng)
      end
    end
  end
  describe 'representative piece' do
    it 'is the first returned by art_pieces' do
      artist.representative_piece.should eql artist.art_pieces[0]
      artist.representative_piece.should eql artist.representative_pieces(1)[0]
    end
    it 'calls Cache.write if Cache.read returns nil' do
      ap = ArtPiece.find_by_artist_id(artist.id)
      Rails.cache.stub(read: nil)
      Rails.cache.should_receive(:write).once
      artist.stub(art_pieces: [ap])
      artist.representative_piece.should eql ap
    end
    it 'doesn\'t call Cache.write if Cache.read returns something' do
      Rails.cache.stub(read: artist.art_pieces[0])
      Rails.cache.should_receive(:write).never
      artist.representative_piece
    end
    it 'doesn\'t call Cache.write if there are no art pieces' do
      Rails.cache.stub(read: nil)
      Rails.cache.should_receive(:write).never
      artist.stub(art_pieces: [])
      artist.representative_piece.should eql nil
    end
  end
  describe 'representative pieces' do
    context 'when the artist has none' do
      let(:artist) { wayout_artist }
      it { artist.representative_pieces(20).should be_empty }
    end
    context 'when the artist has art' do
      it 'is the list of art pieces' do
        artist.representative_pieces(3).should eql artist.art_pieces[0..2]
      end
      it 'returns only as many pieces as the artist has' do
        artist.representative_pieces(1000).should eql artist.art_pieces.all
        artist.representative_pieces(1000).count.should be < 1000
      end
    end
  end

  describe 'representative piece' do
    it 'is included in the users art pieces' do
      artist.art_pieces.should include artist.representative_piece
    end
    it 'is nil for users with no art pieces' do
      wayout_artist.representative_piece.should be_nil
    end
    it 'is the same as the first piece from art_pieces' do
      artist.representative_piece.should eql artist.art_pieces[0]
    end
  end

  describe 'destroying artists' do
    let(:quentin) { create(:artist, :with_art) }
    let(:art_piece) { quentin.art_pieces.first }
    context "then artist removes that artpiece" do
      before do
        artist.add_favorite(art_piece)
        artist.add_favorite(quentin)

        # validate fixtures setup
        expect(artist.favorites.map(&:favoritable_id)).to include art_piece.id

        art_piece.destroy
      end
      it "art_piece is no longer in users favorite list" do
        expect(artist.reload.favorites.map(&:favoritable_id)).to_not include art_piece.id
      end
    end
  end

  describe 'qrcode' do
    before do
      artist
    end
    it 'generates a qr code the first time' do
      File.stub(:exists? => false)
      outpath = File.join(Rails.root, "public/artistdata/#{artist.id}/profile/qr.png")
      str = "http://#{Conf.site_url}/artists/#{artist.id}?qrgen=auto"
      Qr4r.should_receive(:encode).with(str, outpath, border: 15, pixel_size: 5)
      artist.qrcode
    end
  end

  describe '#tally_os' do
    before do
      artist
    end
    it 'tallies today\'s os participants' do
      expect{ Artist.tally_os }.to change(OpenStudiosTally, :count).by(1)
    end
    it 'only records 1 entry per day' do
      expect{
        2.times { Artist.tally_os }
      }.to change(OpenStudiosTally, :count).by(1)
    end

    it 'updates the record if it runs more than once 1 entry per day' do
      Artist.tally_os
      a = Artist.all.reject{|a| a.doing_open_studios?}.first
      t = OpenStudiosTally.last
      a.artist_info.update_os_participation(open_studios_event.key, true)
      a.artist_info.save
      Artist.tally_os
      OpenStudiosTally.last.count.should eql(t.count + 1)
    end

  end

  describe 'doing_open_studios?' do
    before do
      artist_without_studio
      artist.update_os_participation open_studios_event.key, true
    end

    it 'returns true for an artist doing this open studios (with no args)' do
      doing, notdoing = Artist.all.partition(&:doing_open_studios?)
      doing.should have_at_least(1).artists
      notdoing.should have(Artist.count - 1).artists
    end
  end

  describe 'art piece helpers' do
    before do
      artist
    end
    it "most recent art piece should be the representative" do
      artist.representative_piece.title.should be_present
    end

    it "returns art_pieces in by created at if there is no order" do
      artist.art_pieces.should eql artist.art_pieces.sort_by(&:created_at).reverse
    end

    it "returns art_pieces in by created at, then order if there is order" do
      artist.art_pieces.reverse.each_with_index do |ap, idx|
        ap.update_attribute :position, idx
      end
      expect(artist.art_pieces.map(&:position)).to be_strictly_decreasing
    end
  end

  describe 'named scopes' do
    before do
      artist
      wayout_artist
    end
    describe 'with_representative_image' do
      it 'returns only artists with a representative image' do
        active = Artist.active
        w_image = Artist.active.with_representative_image.all
        active.count.should_not eql w_image.count
        active.select{|a| a.representative_piece.blank?}.should have_at_least(1).item
        w_image.select{|a| a.representative_piece.blank?}.should be_empty
      end
    end
    describe 'open_studios_participants' do
      before do
        artist.update_os_participation open_studios_event.key, true
      end

      it 'returns 0 artists for an unknown os' do
        expect(Artist.open_studios_participants('200810').count).to eql 0
      end
      it "returns 1 artist(s) for the current open studios" do
        artists = Artist.open_studios_participants
        artists.should have(1).artists
      end
    end
  end
end
