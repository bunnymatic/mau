require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module StudioSpecHelper
  def valid_studio_attributes(opts = {})
    { :name => "The Blue Studio",
      :street => "2111 Mission St",
      :city => "San Francisco",
      :state => "CA",
      :zip => "94117",
      :url => "http =>//thebluestudio.org",
      :lat => 37.7633243,
      :lng => -122.4195114,
      :phone => '415-123-4154'
    }.merge(opts)
  end
end


describe Studio do
  
  include StudioSpecHelper

  fixtures :studios, :users, :artist_infos

  describe 'address' do 
    it "responds to address" do
      (studios(:s1890).respond_to? :address).should be
    end
    it "responds to full address" do
      studios(:s1890).should respond_to :full_address
    end
    it "responds to address_hash" do
      studios(:s1890).should respond_to :address_hash
    end
  end

  describe 'create' do
    before do
      @s = Studio.new
      @s.attributes = valid_studio_attributes
    end
    it "studio is valid" do
      @s.should be_valid
    end
    it "save triggers geocode" do
      @s.expects(:compute_geocode).returns([-37,122])
      @s.save
    end
    it "validates phone number" do
      @s.save
      @s.reload
      @s.phone.should == '4151234154'
    end
  end

  describe 'update' do 
    it "triggers geocode given new street" do
      
      s = studios(:s1890)
      s.street = '1891 Bryant St'
      s.expects(:compute_geocode).returns([-37,122])
      s.save!
    end
  end
  
  describe 'formatted_phone' do
    it "returns nicely formatted phone #" do
      Studio.any_instance.expects(:phone).returns('4156171234')
      studios(:s1890).formatted_phone.should == '(415) 617-1234'
    end
  end
  
  describe 'to_json' do
    [:created_at, :updated_at].each do |field|
      it "does not include #{field} by default" do
        JSON.parse(studios(:s1890).to_json)['studio'].should_not have_key field.to_s
      end
    end
    it "includes name" do
      JSON.parse(studios(:s1890).to_json)['studio']['name'].should == studios(:s1890).name
    end
    it 'includes created_at if we except other fields' do
      s = JSON.parse(studios(:s1890).to_json(:except => :name))
      s['studio'].should have_key 'created_at'
      s['studio'].should_not have_key 'name'
    end
    it 'includes the artist list if we ask for it' do
      studio = Studio.all.select{|s| s.artists.count > 1}.first
      assert !studio.nil?, 'You need to fix your fixtures so at least 1 studio has at least 1 artist'
      s = JSON.parse(studio.to_json(:methods => 'artists'))
      s['studio']['artists'].should be_a_kind_of Array
      s['studio']['artists'][0]['artist']['firstname'].should == studio.artists.first.firstname
    end
  end
end
