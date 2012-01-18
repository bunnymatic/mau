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

  fixtures :artist_infos, :users, :art_pieces

  describe 'representative piece' do
    it 'is the first returned by art_pieces' do
      a = artist_infos(:artist1)
      a.representative_piece.should == a.artist.art_pieces[0]
      a.representative_piece.should == a.representative_pieces(1)[0]
    end
    it 'calls Cache.write if Cache.read returns nil' do
      ap = ArtPiece.find_by_artist_id(users(:artist1).id)
      a = artist_infos(:artist1)
      Rails.cache.stubs(:read).returns(nil)
      Rails.cache.expects(:write).once
      Artist.any_instance.stubs(:art_pieces).returns([ap])
      a.artist.representative_piece
    end    
    it 'doesn\'t calls Cache.write if Cache.read returns something' do
      a = artist_infos(:artist1)
      Rails.cache.stubs(:read).returns(users(:artist1).art_pieces[0])
      Rails.cache.expects(:write).never
      a.representative_piece
    end    
  end
  describe 'representative pieces' do
    it 'returns nil if there are no art pieces' do
      a = artist_infos(:badname)
      a.representative_pieces(20).should be_empty
    end
    it 'is the list of art pieces' do
      a = artist_infos(:artist1)
      a.representative_pieces(3).should == a.artist.art_pieces[0..2]
    end
    it 'returns only as many pieces as the artist has' do
      a = artist_infos(:artist1)
      assert(a.artist.art_pieces.count <= 1000)
      a.representative_pieces(1000).should == a.artist.art_pieces
    end
  end
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
      u = users(:joeblogs)
      u.artist_info = s
      u.save
    end
    
    describe 'studio number' do
      before do
        artist_infos(:joeblogs).studionumber.should be_nil
        users(:joeblogs).studionumber.should be_nil
      end
      it 'should read from user table'
      it 'should read from artist info table'
    end

    describe "open studios participation" do
      describe 'get' do
        it "returns true if participation is 'true'" do
          ArtistInfo.any_instance.stubs('open_studios_participation').returns('date|other')
          s = artist_infos(:joeblogs)
          s.os_participation['date'].should be_true
        end
        it "returns true if participation is 'on'" do
          ArtistInfo.any_instance.stubs('open_studios_participation').returns('date|ohre')
          s = artist_infos(:joeblogs)
          s.os_participation['date'].should be_true
        end
        it "returns nil if participation is 'false'" do
          ArtistInfo.any_instance.stubs('open_studios_participation').returns('data|something')
          s = artist_infos(:joeblogs)
          s.os_participation['date'].should be_nil
        end
      end

      describe 'add entry' do
        it "adding with = given = { '201104' => true } sets os_participation['201104']" do
          s = artist_infos(:joeblogs)
          s.os_participation = { '201104' => true }
          s.save
          s.reload
          s.os_participation.class.should == Hash
          s.os_participation['201104'].should == true
        end
        it "adding with update_os_participation[ '201104', true] sets os_participation['201104']" do
          s = artist_infos(:joeblogs)
          s.update_os_participation('201104', true)
          s.save
          s.reload
          s.os_participation.class.should == Hash
          s.os_participation['201104'].should == true
        end
      end
      describe 'update' do
        before do
          @s = artist_infos(:joeblogs)
          @s.open_studios_participation = '201104'
          @s.save
          @s.reload
        end
        it "sets false using = {'201104',false}" do
          @s.os_participation = {'201104' => false}
          @s.save
          @s.reload
          @s.os_participation['201104'].should be_nil
        end
        it "sets false given update('201104',false)" do
          @s.update_os_participation('201104', false)
          @s.save
          @s.reload
          @s.os_participation['201104'].should be_nil
        end
        it "sets false given update('201104','false')" do
          @s.os_participation= {'201104'=>'false'}
          @s.save
          @s.reload
          @s.os_participation['201104'].should be_nil
        end
        it 'adds another key properly using update' do
          @s.update_os_participation('201114', true)
          @s.save
          @s.reload
          @s.os_participation['201114'].should be_true
          @s.os_participation['201104'].should be_true
        end
        it 'adds another key properly using =' do
          @s.os_participation = {'201204' => true }
          @s.save
          @s.reload
          @s.os_participation['201204'].should be_true
          @s.os_participation['201104'].should be_true
        end
      end
    end
  end
end
