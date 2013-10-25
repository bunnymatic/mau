require 'spec_helper'

describe Enumerable do
  describe '#uniq_by' do
    let(:testdata) { 4.times.map{|n| Hashie::Mash.new({:name => 'obj', :idx => n})} }
    it 'returns a uniq list of objects uniq\'d by a proc like name' do
      testdata.uniq_by(&:name).should have(1).item
    end
    it 'returns a uniq list of objects uniq\'d by a proc like idx' do
      testdata.uniq_by(&:idx).should have(4).items
    end
    it 'returns a uniq list of objects uniq\'d by a proc like a computation ' do
      uniq_list = testdata.uniq_by{|d| d.name + (d.idx % 2).to_s}
      uniq_list.should have(2).items
      uniq_list.map(&:idx).should eql [0,1]
    end
  end
end
