# frozen_string_literal: true
require 'rails_helper'

describe SafeCache do
  describe 'read' do
    it 'returns nothing on error' do
      expect(Rails.cache).to receive(:read).and_raise(Dalli::RingError.new)
      expect(SafeCache.read('blow')).to eql nil
    end
  end

  describe 'write' do
    it 'returns nothing on error' do
      expect(Rails.cache).to receive(:write).and_raise(Dalli::RingError.new)
      SafeCache.write('here', 'stuff to cache', option1: 'the opt')
    end
  end

  describe 'delete' do
    it 'returns nothing on error' do
      expect(Rails.cache).to receive(:delete).and_raise(Dalli::RingError.new)
      expect(SafeCache.delete('blow')).to eql nil
    end
  end
end
