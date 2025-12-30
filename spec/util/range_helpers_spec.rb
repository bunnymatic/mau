require_relative '../spec_helper'
require_relative '../../lib/util/range_helpers'

describe 'RangeHelpers' do
  include RangeHelpers

  describe '.overlap?' do
    [
      [1..2, 1..4],
      [3..4, 1..3.5],
      [3..4, 1..3],
    ].each do |range|
      it "returns true if ranges overlap like #{range}" do
        expect(RangeHelpers.overlap?(*range)).to eq true
      end
    end
    [
      [1..2, 3..4],
      [3..4, 1..2],
    ].each do |range|
      it "returns false if ranges do not overlap like #{range}" do
        expect(RangeHelpers.overlap?(*range)).to eq false
      end
    end
  end

  describe '.merge' do
    [
      [1..2, 1..4],
      [3..4, 1..3.5],
      [1..2, 3..4],
    ].each do |range|
      it "merges ranges like #{range}" do
        expect(RangeHelpers.merge(*range)).to eq 1..4
      end
    end
  end

  describe '.merge_overlapping' do
    it 'merges overlapping ranges' do
      expect(RangeHelpers.merge_overlapping([1..2, 2..3, 3..4, 5..7, 6..8, 7..12])).to eq([1..4, 5..12])
    end
  end
end
