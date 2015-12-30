require 'rails_helper'

describe StatsCalculator do

  let(:data) { %w| a a b b c d d d d | }
  subject(:calc) { StatsCalculator }
  describe '#histogram' do
    it 'computes a histogram from a hash' do
      expect(calc.new(data).histogram).to eql( { "a" => 2, "b" => 2, "c" => 1, "d" => 4})
    end
  end
  describe '.histogram' do
    it 'computes a histogram from a hash' do
      expect(calc.histogram(data)).to eql( { "a" => 2, "b" => 2, "c" => 1, "d" => 4})
    end
  end

end
