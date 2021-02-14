require 'rails_helper'

describe StatsCalculator do
  let(:data) { %w[a a b b c d d d d] }
  subject(:calc) { StatsCalculator }
  describe '#histogram' do
    it 'computes a histogram from a hash' do
      expect(calc.new(data).histogram).to eql('a' => 2, 'b' => 2, 'c' => 1, 'd' => 4)
    end
  end
  describe '.histogram' do
    it 'computes a histogram from a hash' do
      expect(calc.histogram(data)).to eql('a' => 2, 'b' => 2, 'c' => 1, 'd' => 4)
    end
  end

  describe StatsCalculator::Histogram do
    describe 'initialize' do
      it 'creates an empty histogram with no params' do
        expect(described_class.new).to be_empty
      end
      it 'fills the hash if data is provided' do
        expect(described_class.new(a: 1, b: 2)).to eql(a: 1, b: 2)
      end
      it 'throws an ValueError if the input data is not a hash' do
        expect { described_class.new('whatever') }.to raise_error(StatsCalculator::Histogram::ValueError)
      end
    end

    describe '#add' do
      subject(:histogram) { described_class.new }
      it 'adds data to the histogram' do
        histogram.add(:a)
        expect(histogram).to eql(a: 1)
        histogram.add(:b)
        histogram.add(:a)
        expect(histogram).to eql(a: 2, b: 1)
      end

      it 'throws an ValueError if the key is nil' do
        expect { histogram.add(nil) }.to raise_error(StatsCalculator::Histogram::ValueError)
      end
    end

    describe '#append' do
      subject(:histogram) { described_class.new(a: 1, b: 2) }
      it 'adds data to the histogram' do
        histogram.append(a: 1, b: 2, c: 1)
        expect(histogram).to eql(a: 2, b: 4, c: 1)
      end
    end
  end
end
