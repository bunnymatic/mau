require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module StudioSpecHelper
  def valid_studio_attributes
    { :name => "The Blue Studio",
      :street => "2111 Mission St",
      :city => "San Francisco",
      :state => "CA",
      :zip => "94117",
      :url => "http =>//thebluestudio.org",
      :lat => 37.7633243,
      :lng => -122.4195114
    }
  end
end


describe Studio do
  
  include StudioSpecHelper

  fixtures :studios

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
    describe "with valid attrs" do
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
end
