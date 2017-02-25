# frozen_string_literal: true
require 'rails_helper'

describe ArtSampler do
  describe 'initialization' do
    it 'with a hash sets the values properly' do
      expect((ArtSampler.new seed: 1).seed).to eql 1
    end
    it 'with a hash sets the values properly' do
      expect((ArtSampler.new offset: 2).offset).to eql 2
    end
    it 'defaults the seed to the time' do
      Timecop.freeze
      expect(ArtSampler.new.seed).to eql Time.zone.now.to_i
    end
    it 'defaults the offset to 0' do
      expect(ArtSampler.new.offset).to eql 0
    end
  end
end
