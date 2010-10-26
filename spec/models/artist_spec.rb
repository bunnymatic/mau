require 'spec_helper'

module ArtistSpecHelper
  def valid_user_attributes
    { :email => "joe@bloggs.com",
      :login => "joebloggs",
      :password => "abcdefg",
      :password_confirmation => "abcdefg",
      :firstname => 'joe',
      :lastname => 'blogs',
    }
  end
end

describe Artist, 'creation'  do
  include ArtistSpecHelper
  
  it "should not be valid artist from blank new artist" do
    a = Artist.new
    a.should_not be_valid
    a.should have(2).error_on(:password)
    a.should have(1).error_on(:password_confirmation)
    a.should have(2).error_on(:firstname)
    a.should have(2).error_on(:lastname)
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

describe Artist, "update" do
  include ArtistSpecHelper
  it "should update bio" do
    a = Artist.new
    a.attributes = valid_user_attributes
    a.save.should be_true
    a.bio.should be_nil
    a.bio = 'stuff'
    a.save.should be_true
    artist_id = a.id
    a = nil
    a = Artist.find(artist_id)
    a.bio.should == 'stuff'
  end

  it "should update email settings" do
    a = Artist.new
    a.attributes = valid_user_attributes
    a.save.should be_true
    attr_hash = JSON::parse(a.email_attrs)
    attr_hash['fromartist'].should eql(true)
    attr_hash['mauadmin'].should eql(true)
    attr_hash['maunews'].should eql(true)
    attr_hash['fromall'].should eql(false)

    attr_hash['maunews'] = false
    a.email_attrs = attr_hash.to_json
    a.save
    artist_id = a.id
    a = nil
    a = Artist.find(artist_id)
    attr_hash = JSON::parse(a.email_attrs)
    attr_hash['fromartist'].should eql(true)
    attr_hash['mauadmin'].should eql(true)
    attr_hash['maunews'].should eql(false)
    attr_hash['fromall'].should eql(false)
  end
end

