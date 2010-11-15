require 'spec_helper'

describe Favorite do
  before(:each) do
    @valid_attributes = {
      :obj_id => 1,
      :obj_type => "ArtPiece"
    }
    @invalid_attributes = {
      :obj_id => 1,
      :obj_type => "Nothing"
    }
    @invalid_attributes2 = {
      :obj_id => 1,
      :obj_type => "NotAnArtPiece"
    }
  end

  it "should create a new instance given valid attributes" do
    Favorite.create!(@valid_attributes)
  end

  it "should not create a new instance with nothing" do
    f = Favorite.new()
    f.valid?.should be_false
    f.errors_on(:obj_id).should have(1).items
    f.errors_on(:obj_type).should have(2).items
  end

  it "should not create a new instance with invalid attribute type" do
    f = Favorite.create(@invalid_attributes)
    f.errors.on(:obj_id).should be_nil
    f.errors_on(:obj_type).should have(1).items
  end
  it "should not create a new instance with invalid attribute type which is contains a substring of a valid attribute" do
    f = Favorite.create(@invalid_attributes2)
    f.errors.on(:obj_id).should be_nil
    f.errors_on(:obj_type).should have(1).items
  end
  
  context "after adding one by a user" do
    before do
      @prev = Favorite.find_by_user(10).count
      attrs = @valid_attributes
      attrs[:user_id] = 10
      f = Favorite.create!(attrs)
      f.save
    end
    it "find_by_user should return 1" do
      Favorite.find_by_user(10).count.should eql(@prev+1)
    end
  end
end
