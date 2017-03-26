# frozen_string_literal: true
require 'rails_helper'

describe Medium do
  let!(:art_pieces) { create_list :art_piece, 2 }
  let!(:media) { create_list :medium, 3 }
  describe 'flush_cache' do
    it 'flushes the cache' do
      expect(SafeCache).to receive(:delete).with([:medfreq, true])
      expect(SafeCache).to receive(:delete).with([:medfreq, false])
      Medium.flush_cache
    end
  end

  describe '#frequency' do
    it 'tries the cache on the first hit' do
      expect(SafeCache).to receive(:read).with([:medfreq, true]).and_return(nil)
      expect(SafeCache).to receive(:write)
      Medium.frequency(true)
    end
    it 'does not update the cache if it succeeds' do
      expect(SafeCache).to receive(:read).with([:medfreq, true]).and_return(frequency: 'stuff')
      expect(SafeCache).not_to receive(:write)
      Medium.frequency(true)
    end
  end
end
