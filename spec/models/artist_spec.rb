require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module ArtistSpecHelper
  def valid_user_attributes
    { :email => "joey@bloggs.com",
      :login => "joeybloggs",
      :password => "yabcdefg",
      :password_confirmation => "yabcdefg",
      :firstname => 'joey',
      :lastname => 'blogs'
    }
  end
end

describe Artist do
  include ArtistSpecHelper
  fixtures :users, :artist_infos, :studios, :art_pieces
  before do
    Rails.cache.stubs(:read).returns(nil)
  end
  describe "create" do
    describe 'auth helpers' do
      describe "make token " do
        before do
          @token = Artist.make_token
        end
        it "returns a string greater than 20 chars" do
          @token.length.should > 20
        end
        it "returns a string with only numbers and letters" do
          @token.should_not match /\W+/
        end
        it "when called again returns something different" do
          @token.should_not eql(Artist.make_token)
        end
      end
      describe "make activation token " do
        before do
          a = Artist.new
          a.attributes = valid_user_attributes
          a.should be_valid
          @a = a
          @token = a.make_activation_code
        end
        it "returns a string greater than 20 chars" do
          @token.length.should > 20
        end
        it "returns a string with only numbers and letters" do
          @token.should_not match /\W+/
        end
        it "when called again returns something different" do
          @token.should_not eql(@a.make_activation_code)
        end
      end
    end

    describe "validation" do
      it "should not be valid artist from blank new artist" do
        a = Artist.new
        a.should_not be_valid
        a.should have(2).error_on(:password)
        a.should have(1).error_on(:password_confirmation)
        a.should have_at_least(2).error_on(:login)
        a.should have(3).error_on(:email)
      end
      
      it "should be valid artist" do 
        a = Artist.new
        a.attributes = valid_user_attributes
        a.should be_valid
      end

      it "should be require password confirmation" do
        a = Artist.new
        a.attributes = valid_user_attributes.except(:password_confirmation)
        a.should have(1).error_on(:password_confirmation)
      end

      it "should be not allow 'reserved' names for users" do 
        reserved = [ 'addprofile','delete','destroy','deleteart',
                     'deactivate','add','new','view','create','update']

        a = Artist.new
        a.attributes = valid_user_attributes.except(:login)
        reserved.each do |login|
          a.login = login
          a.should_not be_valid
          a.should have_at_least(1).error_on(:login)
        end
      end
      
      it "should not allow 'bogus email' for email address" do 
        a = Artist.new
        a.attributes = valid_user_attributes.except(:email)
        a.email = 'bogus email'
        a.should_not be_valid
        a.should have_at_least(1).error_on(:email)
      end

      it "should not allow '   ' for email" do 
        a = Artist.new
        a.attributes = valid_user_attributes.except(:email)
        a.email = '   '
        a.should_not be_valid
        a.should have_at_least(1).error_on(:email)
      end
      it "should not allow blow@ for email" do 
        a = Artist.new
        a.attributes = valid_user_attributes.except(:email)
        a.email = 'blow@'
        a.should_not be_valid
        a.should have_at_least(1).error_on(:email)
      end
    end
  end

  describe "update" do
    before do 
      @a = users(:artist1)
    end
    it "should update bio" do
      @a.bio = 'stuff'
      @a.artist_info.save.should be_true
      a = Artist.find(@a.id)
      a.bio.should == 'stuff'
    end

    it "should update email settings" do
      attr_hash = JSON::parse(@a.email_attrs)
      attr_hash['fromartist'].should eql(true)
      attr_hash['mauadmin'].should eql(true)
      attr_hash['maunews'].should eql(true)
      attr_hash['fromall'].should eql(false)
      attr_hash['favorites'].should be_nil

      attr_hash['maunews'] = false
      attr_hash['favorites'] = false
      @a.emailsettings = attr_hash
      @a.save
      @a.reload
      attr_hash = @a.emailsettings
      attr_hash['fromartist'].should eql(true)
      attr_hash['mauadmin'].should eql(true)
      attr_hash['maunews'].should eql(false)
      attr_hash['fromall'].should eql(false)
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
          u.send(method).should == u.artist_info.send(method)
        end
      end
    end
    describe 'studio + artist info' do
      it "returns studio address" do
        a = users(:jesseponce)
        @address_methods.each do |method|
          a.send(method).should_not be_nil
          a.send(method).should == a.studio.send(method)
        end
      end
    end
    describe 'neither address in artist info nor studio' do
      it "returns empty for address" do
        users(:noaddress).send(:address).should be_empty
        hsh = users(:noaddress).send(:address_hash)
        hsh[:geocoded].should be_false
        hsh[:parsed][:street].should be_nil
        hsh[:latlng].should == [nil,nil]
      end
    end
  end
  describe 'in_the_mission?' do
    it "returns true for artist in the mission with no studio" do
      a = users(:joeblogs)
      a.in_the_mission?.should be_true
    end
    it "returns true for artist in the mission with a studio in the mission" do
      users(:jesseponce).in_the_mission?.should be_true
    end
    it "returns false for artist with wayout address" do
      a = users(:wayout)
      a.in_the_mission?.should be_false
    end
    it "returns true for artist with wayout address but studio in the mission" do
      a = users(:wayout)
      a.studio = studios(:blue)
      a.save
      a.in_the_mission?.should be_true
    end
  end
  describe 'find by fullname' do
    context ' after adding artist with firstname joe and lastname blogs ' do
      it "finds joe blogs" do
        artists = Artist.find_by_fullname('joe blogs')
        artists.length.should eql(1)
        artists[0].get_name.should eql('joe blogs')
      end
      it "finds Joe Blogs" do
        artists = Artist.find_by_fullname('Joe Blogs')
        artists.length.should eql(1)
        artists[0].get_name.should eql('joe blogs')
      end
      it "finds Joe blogs" do
        artists = Artist.find_by_fullname('Joe blogs')
        artists.length.should eql(1)
        artists[0].get_name.should eql('joe blogs')
      end
      it "does not find jo blogs" do
        artists = Artist.find_by_fullname('Jo blogs')
        artists.length.should eql(0)
      end
    end
  end
  describe 'get from info' do
    before do
      @a = users(:artist1)
    end
    it "responds to method bio" do
      lambda { @a.bio }.should_not raise_error
    end
  end
  describe "fetch address" do
    context "without studio association" do
      before do
        @a = users(:wayout)
      end
      it "returns correct street" do
        @a.artist_info.street.should == @a.street
      end
      it "returns correct address" do
        @a.address.should include @a.street
      end
      it "returns correct lat/lng" do
        @a.artist_info.lat.should be
        @a.artist_info.lng.should be
      end
    end
    context 'with studio association' do
      before do
        @a = users(:jesseponce)
      end
      it "returns correct street" do
        @a.artist_info.street.should == @a.street
      end
      it "returns studio address" do
        @a.address.should == @a.address
      end
      it "returns correct artist info lat/lng" do
        @a.artist_info.lat.should be_close(@a.lat, 0.001)
        @a.artist_info.lng.should be_close(@a.lng, 0.001)
      end
    end
  end    
  describe 'primary_medium' do
    fixtures :media
    before do
      @a = users(:artist1)
      media_ids = Medium.find(:all, :order => :name).map(&:id)
      8.times.each do |ct| 
        idx = ((media_ids.count-1)/(ct+1)).to_i
        @a.art_pieces << ArtPiece.new(:title => 'abc', :medium_id => media_ids[idx])
      end
      @a.save 
    end
    it 'finds medium 1 as the most common' do
      @a.primary_medium.should == media(:medium1)
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
      a = users(:artist1)
      a.representative_piece.should == a.art_pieces[0]
    end

  end

  describe 'named scopes' do
    describe ':open_studios_participants' do
      [['201104',2],['201110',3]].each do |arg|
        it "returns #{arg[1]} artist(s) with '#{arg[0]}'" do
          artists = Artist.open_studios_participants(arg[0])
          artists.should have(arg[1]).artists
          artists[0].os_participation[arg[0]].should be_true
        end
      end
    end
  end
end
