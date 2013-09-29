require 'spec_helper'

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

  fixtures :artist_infos, :users, :art_pieces

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
      end
      it "artist_info is valid" do
        ai = ArtistInfo.new valid_artist_info_attributes
        ai.should_receive(:compute_geocode).and_return([-37,122])
        ai.should be_valid
      end
      it "save triggers geocode" do
        ai = ArtistInfo.new valid_artist_info_attributes
        ai.should_receive(:compute_geocode).and_return([-37,122])
        ai.save
      end
    end
  end

  describe 'update' do
    let(:joeblogs) { artist_infos(:joeblogs) }
    it "triggers geocode given new street" do
      s = artist_infos(:joeblogs)
      s.street = '1891 Bryant St'
      s.should_receive(:compute_geocode).and_return([-37,122])
      u = users(:joeblogs)
      u.artist_info = s
      u.save!
    end

    describe "open studios participation" do
      describe 'get' do
        it "returns true if participation is 'true'" do
           joeblogs.should_receive('open_studios_participation').at_least(:once).and_return('date|other')
           joeblogs.os_participation['date'].should be_true
        end
        it "returns nil if participation is missing" do
          joeblogs.should_receive('open_studios_participation').at_least(:once).and_return('date|something')
          joeblogs.os_participation['other'].should be_nil
        end
      end

      describe 'add entry' do
        it "adding with = given = { '201104' => true } sets os_participation['201104']" do
          joeblogs.os_participation = { '201104' => true }
          joeblogs.reload
          joeblogs.os_participation.class.should == Hash
          joeblogs.os_participation['201104'].should == true
        end
        it "adding with update_os_participation[ '201104', true] sets os_participation['201104']" do
          joeblogs.update_os_participation('201104', true)
          joeblogs.save
          joeblogs.reload
          joeblogs.os_participation.class.should == Hash
          joeblogs.os_participation['201104'].should == true
        end
      end
      describe 'update' do
        before do
          joeblogs.open_studios_participation = '201104'
        end
        it "sets false using = {'201104',false}" do
          joeblogs.os_participation = {'201104' => false}
          joeblogs.reload
          joeblogs.os_participation['201104'].should be_nil
        end
        it "sets false given update('201104',false)" do
          joeblogs.update_os_participation('201104', false)
          joeblogs.save
          joeblogs.reload
          joeblogs.os_participation['201104'].should be_nil
        end
        it "sets false given update('201104','false')" do
          joeblogs.os_participation= {'201104'=>'false'}
          joeblogs.reload
          joeblogs.os_participation['201104'].should be_nil
        end
        it 'adds another key properly using update' do
          joeblogs.update_attribute(:open_studios_participation,'201104')
          joeblogs.update_os_participation('201114', true)
          joeblogs.reload
          joeblogs.os_participation['201114'].should be_true
          joeblogs.os_participation['201104'].should be_true
        end
        it 'adds another key properly using =' do
          joeblogs.update_attribute(:open_studios_participation,'201104')
          joeblogs.os_participation = {'201204' => true }
          joeblogs.reload
          joeblogs.os_participation['201204'].should be_true
          joeblogs.os_participation['201104'].should be_true
        end
      end
    end
  end
end
