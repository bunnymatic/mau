require 'spec_helper'

describe ArtPieceTag do

  fixtures :art_piece_tags, :art_pieces_tags, :art_pieces

  it{ should validate_presence_of(:name) }
  it{ should ensure_length_of(:name).is_at_least(3).is_at_most(25) }

  describe 'frequency'  do

    it "should not throw when getting frequency with no tags" do
      expect { ArtPieceTag.frequency }.to_not raise_error
    end

    it "frequency returns normalized frequency correctly" do
      f = ArtPieceTag.frequency
      tags = f.collect {|t| t["tag"]}
      cts = f.collect {|t| t["ct"]}
      tags.should == [art_piece_tags(:one), art_piece_tags(:two), art_piece_tags(:three),  art_piece_tags(:with_spaces)].map(&:id)
      cts.should == [1.0, 0.8, 0.6, 0.4]
    end
    it "frequency returns un-normalized frequency correctly" do
      f = ArtPieceTag.frequency(normalize=false)
      tags = f.collect {|t| t["tag"]}
      cts = f.collect {|t| t["ct"]}
      tags.should == [art_piece_tags(:one), art_piece_tags(:two), art_piece_tags(:three),  art_piece_tags(:with_spaces)].map(&:id)
      cts.should == [5,4,3,2]
    end

  end

end
