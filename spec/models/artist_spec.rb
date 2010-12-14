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
  fixtures :users, :artist_infos, :studios

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
      @ai = artist_infos(:artist1)
      @a.artist_info = @ai
    end
    it "should update bio" do
      @a.bio.should eql(@ai.bio)
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

      attr_hash['maunews'] = false
      @a.email_attrs = attr_hash.to_json
      @a.save
      a = Artist.find(@a.id)
      attr_hash = JSON::parse(a.email_attrs)
      attr_hash['fromartist'].should eql(true)
      attr_hash['mauadmin'].should eql(true)
      attr_hash['maunews'].should eql(false)
      attr_hash['fromall'].should eql(false)
    end
  end
  describe 'find by fullname' do
    context ' after adding artist with firstname joe and lastname blogs ' do
      before do
        @a = users(:joeblogs)
      end
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
      @ai = artist_infos(:artist1)
      @a.artist_info = @ai
    end
    it "responds to method bio" do
      lambda { @a.bio }.should_not raise_error
    end
    it "responds to method osoct2010?" do
      lambda { @a.osoct2010? }.should_not raise_error
    end
    it "responds to method osoct2010" do
      lambda { @a.osoct2010 }.should_not raise_error
    end
  end
  describe "fetch address" do
    context "without studio association" do
      before do
        @a = users(:artist1)
        @a.save!
        @b = artist_infos(:wayout)
        @b.artist_id = @a.id
        @b.save!
      end
      it "returns correct street" do
        @a.artist_info.street.should == @b.street
      end
      it "returns correct address" do
        @a.address.should include @b.street
      end
      it "returns correct lat/lng" do
        @a.artist_info.lat.should be
        @a.artist_info.lng.should be
      end
    end
  end    
end
