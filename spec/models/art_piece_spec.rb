require 'spec_helper'

def valid_attrs()
  { :title => 'art piece',
  }
end

describe ArtPiece do
  fixtures :art_pieces, :users, :artist_infos
  describe 'create'  do
    it 'should not allow short title' do
      ap = ArtPiece.new(:title => 't')
      ap.save.should be_false
      ap.should have(1).errors_on(:title)
    end
    
    it 'should not allow empty title' do
      ap = ArtPiece.new
      ap.save.should be_false
      ap.should have(2).errors
    end
    
    it 'allows quotes' do
      p = valid_attrs.merge({:title => 'what"ever'})
      ap = ArtPiece.new(p)
      ap.valid?.should be_true
    end
    
    it 'encodes quotes to html numerically' do
      p = valid_attrs.merge({:title => 'what"ever'})
      ap = ArtPiece.new(p)
      ap.safe_title.should == 'what&#x22;ever'
    end
  end
  describe 'after save' do
    it 'clears representative image cache and new art cache on save' do
      ap = ArtPiece.first
      Rails.cache.expects(:delete).with("%s%s" % [Artist::CACHE_KEY, ap.artist.id])
      Rails.cache.expects(:delete).with(ArtPiece::NEW_ART_CACHE_KEY)
      ap.title = gen_random_string
      ap.save
    end
  end
  describe "ImageDimensions helper" do
    it "get_scaled_dimensions returns input dimension given art piece with no dimensions" do
      a = art_pieces(:hot)
      a.get_scaled_dimensions(100).should == [100,100]
    end
    it "get_scaled_dimensions returns input given art with negative dim" do 
      a = art_pieces(:negative_size)
      a.get_scaled_dimensions(100).should == [100,100]
    end
    it "get_scaled_dimensions returns the max of the dim given art with dimensions" do
      a = art_pieces(:valid_dimensions)
      a.get_scaled_dimensions(1000).should == [1000,500]
    end
    it "get_min_scaled_dimensions returns the max of the dim given art with dimensions" do
      a = art_pieces(:valid_dimensions)
      a.get_min_scaled_dimensions(400).should == [800,400]
    end
  end

  describe "get_new_art" do 
    before do
      Rails.cache.stubs(:read).returns(nil)
      t = Time.now
      Time.stubs(:now).returns(t)
    end
    it 'returns an array' do
      ArtPiece.get_new_art.should be_a_kind_of Array
    end
    it 'returns art pieces updated between today and 2 days ago' do
      all = ArtPiece.find_by_sql("select * from art_pieces").select{|a| a.artist_id}
      all.length.should >= 1
      aps = ArtPiece.get_new_art
      aps.length.should >=1 
      aps.length.should <=12 
      aps.sort_by(&:created_at).should == all[0..12].sort_by(&:created_at)
    end
    context 'from cache' do
      before do
        Rails.cache.stubs(:read).returns([ArtPiece.last])
      end
      it 'returns pulls from the cache if available' do
        ArtPiece.get_new_art.should == [ArtPiece.last]
      end
    end
  end

  describe 'get_path' do
    it 'returns a path to the art piece' do
      ap = ArtPiece.first
      artist = ap.artist
      ArtPiece.first.get_path.should match %r{/artistdata/#{artist.id}/imgs}
    end
  end

end
