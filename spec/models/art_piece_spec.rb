require 'spec_helper'

describe ArtPiece, 'creation'  do
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
end
