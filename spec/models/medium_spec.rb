require 'spec_helper'

describe Medium do

  describe 'flush_cache' do
    it 'flushes the cache' do
      expect(SafeCache).to receive(:delete).with(Medium::CACHE_KEY + true.to_s)
      expect(SafeCache).to receive(:delete).with(Medium::CACHE_KEY + false.to_s)
      Medium.flush_cache
    end
  end

end
