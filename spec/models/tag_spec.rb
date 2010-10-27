require 'spec_helper'

module TagSpecHelper
  LETTERS = [('a'..'z'),('A'..'Z')].map{|i| i.to_a}.flatten;  

  def random_string(len=5)
    if len < 0 or len > 100
      return "bogus"
    end
    n = LETTERS.length
    (0..len).map{ LETTERS[rand(n)]  }.join;
  end

  def random_tag
    { :name => random_string(10) }
  end
end

describe Tag, 'creation'  do
  include TagSpecHelper

  it "should create tag" do
    t = Tag.new
    t.attributes = random_tag
    t.should be_valid
  end

  it "should not create an empty tag" do
    t = Tag.new
    t.should_not be_valid
  end

end
  
describe Tag, 'frequency'  do
  include TagSpecHelper

  it "should not throw when getting frequency with no tags" do
    lambda { Tag.frequency }.should_not raise_error
  end

  it "should get frequency" do
    
    tags = [ Tag.new(:name => 'one'), Tag.new(:name => 'two') ]
    ap = ArtPiece.new(:title => 'tt', :tags => tags)
    ap.save!

    tags = [ Tag.new(:name => 'three'), Tag.new(:name => 'two') ]
    ap = ArtPiece.new(:title => 't2', :tags => tags)
    ap.save!

    ap = ArtPiece.new(:title => 'trauma', :tags => tags)
    ap.save!

    ap = ArtPiece.new(:title => 'trauma', :tags => tags)
    ap.save!

    f = Tag.frequency
    tags = f.collect {|t| t["tag"]}
    cts = f.collect {|t| t["ct"]}
    tags.should == ["3","4","1","2"]
    cts.should == [1.0,1.0,(1.0/3.0),(1.0/3.0)]

    f = Tag.frequency(normalize=false)
    tags = f.collect {|t| t["tag"]}
    cts = f.collect {|t| t["ct"]}
    tags.should == ["3","4","1","2"]
    cts.should == [3,3,1,1]
  end

end

