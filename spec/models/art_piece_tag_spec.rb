require 'spec_helper'

describe ArtPieceTag do

  let(:artists) { FactoryGirl.create_list :artist, 2, :with_tagged_art }
  let(:art_pieces) { artists.map(&:art_pieces).flatten }

  it{ should validate_presence_of(:name) }
  it{ should ensure_length_of(:name).is_at_least(3).is_at_most(25) }

  describe 'frequency'  do
    before do
      tags = FactoryGirl.create_list :art_piece_tag, 5
      art_pieces.each_with_index do |ap, idx|
        ap.tags = tags[0..(4-idx)]
        ap.save!
      end
    end

    it "should not throw when getting frequency with no tags" do
      expect { ArtPieceTag.frequency }.to_not raise_error
    end

    it "frequency returns normalized frequency correctly" do
      f = ArtPieceTag.frequency
      tags = f.collect {|t| t["tag"]}
      cts = f.collect {|t| t["ct"]}
      expect(cts).to eql [1.0, 0.8, 0.6, 0.4, 0.2]
      expect(tags.first).to eql art_pieces.first.id
    end
    it "frequency returns un-normalized frequency correctly" do
      f = ArtPieceTag.frequency(normalize=false)
      tags = f.collect {|t| t["tag"]}
      cts = f.collect {|t| t["ct"]}
      expect(cts).to eql [5,4,3,2,1]
      expect(tags.last).to eql art_pieces.last.id
    end

    it 'tries the cache on the first hit' do
      expect(SafeCache).to receive(:read).with([:tagfreq, true]).and_return(nil)
      expect(SafeCache).to receive(:write)
      ArtPieceTag.frequency(true)
    end
    it 'does not update the cache if it succeeds' do
      expect(SafeCache).to receive(:read).with([:tagfreq, true]).and_return({:frequency => 'stuff'})
      expect(SafeCache).not_to receive(:write)
      ArtPieceTag.frequency(true)
    end
  end

  describe 'flush_cache' do
    it 'flushes the cache' do
      expect(SafeCache).to receive(:delete).with([:tagfreq, true])
      expect(SafeCache).to receive(:delete).with([:tagfreq, false])
      ArtPieceTag.flush_cache
    end
  end

end
