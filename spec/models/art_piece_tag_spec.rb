require 'spec_helper'

describe ArtPieceTag do

  fixtures :art_piece_tags, :art_pieces_tags, :art_pieces

  it{ should validate_presence_of(:name) }
  it{ should ensure_length_of(:name).is_at_least(3).is_at_most(25) }

  describe 'frequency'  do

    let(:expected_order) {
      [:one, :two, :three, :with_spaces].map{|k| art_piece_tags(k).id}
    }
    it "should not throw when getting frequency with no tags" do
      expect { ArtPieceTag.frequency }.to_not raise_error
    end

    it "frequency returns normalized frequency correctly" do
      f = ArtPieceTag.frequency
      tags = f.collect {|t| t["tag"]}
      cts = f.collect {|t| t["ct"]}
      tags.should eql expected_order
      cts.should == [1.0, 0.8, 0.6, 0.4]
    end
    it "frequency returns un-normalized frequency correctly" do
      f = ArtPieceTag.frequency(normalize=false)
      tags = f.collect {|t| t["tag"]}
      cts = f.collect {|t| t["ct"]}
      tags.should eql expected_order
      cts.should == [5,4,3,2]
    end

    it 'tries the cache on the first hit' do
      expect(SafeCache).to receive(:read).with(ArtPieceTag::CACHE_KEY + true.to_s).and_return(nil)
      expect(SafeCache).to receive(:write)
      ArtPieceTag.frequency(true)
    end
    it 'does not update the cache if it succeeds' do
      expect(SafeCache).to receive(:read).with(ArtPieceTag::CACHE_KEY + true.to_s).and_return({:frequency => 'stuff'})
      expect(SafeCache).not_to receive(:write)
      ArtPieceTag.frequency(true)
    end
  end

  describe 'flush_cache' do
    it 'flushes the cache' do
      expect(SafeCache).to receive(:delete).with(ArtPieceTag::CACHE_KEY + true.to_s)
      expect(SafeCache).to receive(:delete).with(ArtPieceTag::CACHE_KEY + false.to_s)
      ArtPieceTag.flush_cache
    end
  end

end
