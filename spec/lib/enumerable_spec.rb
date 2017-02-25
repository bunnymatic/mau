# frozen_string_literal: true
require 'rails_helper'

describe Enumerable do
  describe '#uniq_by' do
    let(:testdata) { Array.new(4){|n| Hashie::Mash.new(name: 'obj', idx: n)} }
    it 'returns a uniq list of objects uniq\'d by a proc like name' do
      expect(testdata.uniq_by(&:name).size).to eq(1)
    end
    it 'returns a uniq list of objects uniq\'d by a proc like idx' do
      expect(testdata.uniq_by(&:idx).size).to eq(4)
    end
    it 'returns a uniq list of objects uniq\'d by a proc like a computation ' do
      uniq_list = testdata.uniq_by{|d| d.name + (d.idx % 2).to_s}
      expect(uniq_list.size).to eq(2)
      expect(uniq_list.map(&:idx)).to eql [0,1]
    end
  end
end
