require 'spec_helper'

describe SafeCache do

  describe 'read' do
    it "returns nothing on error" do
      Rails.cache.should_receive(:read).and_raise(Dalli::RingError.new)
      SafeCache.read('blow').should eql nil
    end
  end

  describe 'write' do
    it "returns nothing on error" do
      Rails.cache.should_receive(:write).and_raise(Dalli::RingError.new)
      SafeCache.write("here", "stuff to cache", {:option1 => 'the opt'})
    end
  end

  describe 'delete' do
    it "returns nothing on error" do
      Rails.cache.should_receive(:delete).and_raise(Dalli::RingError.new)
      SafeCache.delete('blow').should eql nil
    end
  end

end
