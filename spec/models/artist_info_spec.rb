require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module ArtistInfoSpecHelper
  def valid_artist_info_attributes
    { :street => "2111 Mission St",
      :city => "San Francisco",
      :addr_state => "CA",
      :zip => "94117",
    }
  end
end


describe ArtistInfo do
  
  include ArtistInfoSpecHelper

  fixtures :artist_infos

  describe 'address mixin' do 
    it "responds to address" do
      artist_infos(:joeblogs).should respond_to :address
    end
    it "responds to address_hash" do
      artist_infos(:joeblogs).should respond_to :address_hash
    end
    it "responds to full_address" do
      artist_infos(:joeblogs).should respond_to :full_address
    end
  end

  describe 'create' do
    describe "with valid attrs" do
      before do
        @ai = ArtistInfo.new
        @ai.attributes = valid_artist_info_attributes
      end
      it "artist_info is valid" do
        @ai.should be_valid
      end
      it "save triggers geocode" do
        @ai.expects(:compute_geocode).returns([-37,122])
        @ai.save
      end
    end
  end

  describe 'update' do 
    it "triggers geocode given new street" do
      
      s = artist_infos(:joeblogs)
      s.street = '1891 Bryant St'
      s.expects(:compute_geocode).returns([-37,122])
      s.save!
    end
  end
end
