require 'spec_helper'

describe Medium do

  describe 'flush_cache' do
    it 'flushes the cache' do
      expect(SafeCache).to receive(:delete).with(Medium::CACHE_KEY + true.to_s)
      expect(SafeCache).to receive(:delete).with(Medium::CACHE_KEY + false.to_s)
      Medium.flush_cache
    end
  end

  describe '#frequency' do
    it 'tries the cache on the first hit' do
      expect(SafeCache).to receive(:read).with(Medium::CACHE_KEY + true.to_s).and_return(nil)
      expect(SafeCache).to receive(:write)
      Medium.frequency(true)
    end
    it 'does not update the cache if it succeeds' do
      expect(SafeCache).to receive(:read).with(Medium::CACHE_KEY + true.to_s).and_return({:frequency => 'stuff'})
      expect(SafeCache).not_to receive(:write)
      Medium.frequency(true)
    end
  end

end
