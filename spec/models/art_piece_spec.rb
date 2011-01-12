require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

def valid_attrs()
    { :title => 'art piece',
    }
end

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

describe ArtPiece, "get_todays_art" do 
  fixtures :art_pieces
  it 'returns art pieces updated between today and yesterday' do
    all = ArtPiece.find_by_sql("select * from art_pieces")
    all.length.should >= 1
    today = Time.now
    yesterday = (today - 24.hours)
    todays = all.select{|ap| (ap.created_at > yesterday && ap.created_at < today)}.map{|a| a.title}.sort
    aps = ArtPiece.get_todays_art
    aps.length.should >=1 
    taps = aps.map{|a| a.title}.sort
    taps.should == todays
  end
end

