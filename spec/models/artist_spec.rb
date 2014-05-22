require 'spec_helper'

describe Artist do

  fixtures :users, :artist_infos, :studios, :art_pieces, :media, :roles, :roles_users
  before do
    Rails.cache.stub(:read => nil)
  end

  let(:artist) { users(:artist1) }
  let(:artist_info) { artist.artist_info }

  context 'make sure our factories work' do
    it 'creates an artist info' do
      a = FactoryGirl.create(:artist, :active)
      expect(a.artist_info).to be_present
    end
    it 'creates an editor' do
      expect(FactoryGirl.create(:artist, :editor, :active).is_editor?).to be_true
    end
    it 'creates an admin' do
      expect(FactoryGirl.create(:artist, :admin, :active).is_admin?).to be_true
    end
  end

  context 'with an artist that has tags and media' do
    subject { artist }
    its(:tags) { should eql subject.art_pieces.map(&:tags).flatten.compact.uniq }
    its(:media) { should eql subject.art_pieces.map(&:medium).flatten.compact.uniq }
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
    let(:this_artist) { artist }
    it "should update bio" do
      ArtistInfo.any_instance.should_receive(:compute_geocode).and_return([-40,122])

      this_artist.bio = 'stuff'
      this_artist.artist_info.save!
      a = Artist.find(this_artist.id)
      a.bio.should eql 'stuff'
    end

    it "should update email settings" do
      attr_hash = JSON::parse(this_artist.email_attrs)
      attr_hash['fromartist'].should eql(true)
      attr_hash['fromall'].should eql(true)
      attr_hash['favorites'] = false
      this_artist.emailsettings = attr_hash
      this_artist.save
      this_artist.reload
      attr_hash = this_artist.emailsettings
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
        u = users(:joeblogs)
        @address_methods.each do |method|
          u.send(method).should_not be_nil
          u.send(method).should eql u.artist_info.send(method)
        end
      end
    end
    describe 'studio + artist info' do
      it "returns studio address" do
        a = users(:jesseponce)
        @address_methods.each do |method|
          a.send(method).should_not be_nil
          a.send(method).should eql a.studio.send(method)
        end
      end
    end
    describe 'neither address in artist info nor studio' do
      subject(:noaddress) { users(:noaddress) }
      it "returns empty for address" do
        noaddress.send(:address).should be_empty
        hsh = noaddress.send(:address_hash)
        hsh[:geocoded].should be_false
        hsh[:parsed][:street].should be_nil
        hsh[:latlng].should eql [nil,nil]
      end
      its(:has_address?) { should be_false }
    end
  end
  describe 'in_the_mission?' do
    it "returns true for artist in the mission with no studio" do
      a = users(:joeblogs)
      a.should be_in_the_mission
      a.should have_address
    end
    it "returns true for artist in the mission with a studio in the mission" do
      a = users(:jesseponce)
      a.should be_in_the_mission
      a.should have_address
    end
    it "returns false for artist with wayout address" do
      a = users(:wayout)
      a.should_not be_in_the_mission
      a.should have_address
    end
    it "returns true for artist with wayout address but studio in the mission" do
      a = users(:wayout)
      a.studio = studios(:blue)
      a.save
      a.should have_address
      a.should be_in_the_mission
    end
  end
  describe 'find by fullname' do
    let(:artist) { users(:joeblogs) }
    let(:fullname) { 'joe blogs' }
    let(:artists) { Artist.find_by_fullname( fullname ) }
    context 'with lowercase name' do
      it { artists.should have(1).artist }
      it { artists.first.should eql artist }
    end
    context 'with capitalized name search' do
      let(:fullname) { "Joe Blogs" }
      it { artists.should have(1).artist }
      it { artists.first.should eql artist }
    end
    context 'with mixed case search' do
      let(:fullname) { "Joe blogs" }
      it { artists.should have(1).artist }
      it { artists.first.should eql artist }
    end
    context 'with substring' do
      let(:fullname) { "Jo blogs" }
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
      let(:artist) { users(:wayout) }
      it "returns correct street" do
        artist_info.street.should eql artist.street
      end
      it "returns correct address" do
        artist.address.should include artist.street
      end
      it "returns correct lat/lng" do
        artist_info.lat.should be
        artist_info.lng.should be
      end
    end
    context 'with studio association' do
      let(:artist) { users(:jesseponce) }
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
      Rails.cache.stub(:read => nil)
      Rails.cache.should_receive(:write).once
      artist.stub(:art_pieces => [ap])
      artist.representative_piece.should eql ap
    end
    it 'doesn\'t call Cache.write if Cache.read returns something' do
      Rails.cache.stub(:read => artist.art_pieces[0])
      Rails.cache.should_receive(:write).never
      artist.representative_piece
    end
    it 'doesn\'t call Cache.write if there are no art pieces' do
      Rails.cache.stub(:read => nil)
      Rails.cache.should_receive(:write).never
      artist.stub(:art_pieces => [])
      artist.representative_piece.should eql nil
    end
  end
  describe 'representative pieces' do
    context 'when the artist has none' do
      let(:artist) { users(:badname) }
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
  describe 'primary_medium' do
    before do
      media_ids = Medium.find(:all, :order => :name).map(&:id)
      8.times.each do |ct|
        idx = ((media_ids.count-1)/(ct+1)).to_i
        artist.art_pieces << ArtPiece.new(:title => 'abc', :medium_id => media_ids[idx])
      end
      artist.save
    end
    it 'finds medium 1 as the most common' do
      artist.primary_medium.should eql media(:medium1)
    end
    it 'works with no media on artist' do
      lambda {users(:quentin).primary_medium}.should_not raise_error
    end
  end

  describe 'representative piece' do
    before do
      Artist.all.map(&:art_pieces).flatten.count.should > 2
    end
    it 'is included in the users art pieces' do
      Artist.all.each do |a|
        unless a.art_pieces.empty?
          a.art_pieces.should include a.representative_piece
        end
      end
    end
    it 'is nil for users with no art pieces' do
      Artist.all.each do |a|
        if a.art_pieces.empty?
          a.representative_piece.should be_nil
        end
      end
    end
    it 'is the same as the first piece from art_pieces' do
      artist.representative_piece.should eql artist.art_pieces[0]
    end
  end

  describe 'to_json' do
    [:password, :crypted_password, :remember_token, :remember_token_expires_at,
     :salt, :mailchimp_subscribed_at, :deleted_at, :activated_at, :created_at,
     :max_pieces, :updated_at, :activation_code, :reset_code].each do |field|
      it "does not include #{field} by default" do
        JSON.parse(users(:annafizyta).to_json)['artist'].should_not have_key field.to_s
      end
    end
    it "includes firstname" do
      JSON.parse(users(:annafizyta).to_json)['artist']['firstname'].should eql users(:annafizyta).firstname
    end
    it 'includes created_at if we except other fields' do
      a = JSON.parse(users(:annafizyta).to_json(:except => :firstname))
      a['artist'].should have_key 'created_at'
      a['artist'].should_not have_key 'firstname'
    end
    it 'includes the artist info if we ask for it' do
      a = JSON.parse(users(:annafizyta).to_json(:include => :artist_info))
      a['artist']['artist_info'].should be_a_kind_of Hash
    end
  end

  describe 'qrcode' do
    it 'generates a qr code the first time' do
      File.stub(:exists? => false)
      a = Artist.first
      outpath = File.join(Rails.root, "public/artistdata/#{a.id}/profile/qr.png")
      str = "http://#{Conf.site_url}/artists/#{a.id}?qrgen=auto"
      Qr4r.should_receive(:encode).with(str, outpath, :border => 15, :pixel_size => 5)
      a.qrcode
    end
  end

  describe '#tally_os' do
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
      a.artist_info.update_os_participation(Conf.oslive.to_s, true)
      a.artist_info.save
      Artist.tally_os
      OpenStudiosTally.last.count.should eql(t.count + 1)
    end

  end

  describe 'doing_open_studios?' do
    it 'returns true for an artist doing this open studios (with no args)' do
      doing, notdoing = Artist.all.partition(&:doing_open_studios?)
      doing.should have(6).artists
      notdoing.should have(Artist.count - 6).artists
    end
  end

  describe 'default scope' do
    it "most recent art piece should be the representative" do
      artist.representative_piece.title.should eql "third"
    end

    it "returns art_pieces in created time order" do
      artist.art_pieces.should eql artist.art_pieces.sort_by(&:created_at).reverse
    end
  end

  describe 'named scopes' do
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
      [['201104',3],['201110',4]].each do |arg|
        it "returns #{arg[1]} artist(s) with '#{arg[0]}'" do
          artists = Artist.open_studios_participants(arg[0])
          artists.should have(arg[1]).artists
          artists[0].os_participation[arg[0]].should be_true
        end
      end
    end
  end
end
