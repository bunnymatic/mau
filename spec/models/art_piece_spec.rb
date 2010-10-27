require 'spec_helper'

describe ArtPiece, 'creation'  do
  it 'should not allow short title' do
    ap = ArtPiece.new(:title => 't')
    ap.save.should be_false
    ap.errors.on(:title).should == "is too short (minimum is 2 characters)"
  end

  it 'should not allow empty title' do
    ap = ArtPiece.new
    ap.save.should be_false
    ap.errors.should have(2).items
  end
end
