require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

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

describe ArtPiece, "ImageDimensions helper" do
  fixtures :art_pieces
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
    
