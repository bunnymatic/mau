# frozen_string_literal: true
require 'rails_helper'

describe ArtSampler do

  before do
    Timecop.freeze
  end

  after do
    Timecop.return
  end

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

  describe 'pieces' do
    let(:now) { Time.current }

    let(:art_pieces) do
      Array.new(5) do |index|
        create(:art_piece, created_at: (5-index).days.ago, artist: create(:artist, :active) )
      end
    end

    subject(:sampler) { described_class.new(number_of_images: 10) }

    before do
      art_pieces
    end

    it 'returns the most recent pieces always' do
      expect(sampler.pieces[0..1].map(&:model)).to eq art_pieces.last(2).reverse
    end

    it 'returns the most recent pieces always' do
      expect(sampler.pieces[2..-1].map(&:model)).to match_array art_pieces.first(3)
    end
  end
end
