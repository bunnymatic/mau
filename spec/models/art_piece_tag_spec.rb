require 'spec_helper'

module TagSpecHelper
  def random_tag
    { :name => Faker::Lorem.words(2).join(' ') }
  end
end

describe ArtPieceTag do
  include TagSpecHelper
  fixtures :art_piece_tags, :art_pieces_tags, :art_pieces
  describe 'creation'  do
    it "should create tag" do
      t = ArtPieceTag.new
      t.attributes = random_tag
      t.should be_valid
    end

    it "should not create an empty tag" do
      t = ArtPieceTag.new
      t.should_not be_valid
    end

  end

  describe 'frequency'  do
    include TagSpecHelper

    it "should not throw when getting frequency with no tags" do
      lambda { ArtPieceTag.frequency }.should_not raise_error
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
