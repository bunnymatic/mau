# frozen_string_literal: true

require 'rails_helper'

describe ArtPiece do
  let(:valid_attrs) { FactoryBot.attributes_for(:art_piece) }
  let(:artist) { FactoryBot.create(:artist, :active, :with_art) }
  let(:art_piece) { artist.art_pieces.first }

  it { should validate_presence_of(:title) }
  it { should validate_length_of(:title).is_at_least(2).is_at_most(80) }

  describe 'new' do
    it 'allows quotes' do
      p = valid_attrs.merge(title: 'what"ever')
      ap = ArtPiece.new(p)
      expect(ap).to be_valid
    end

    it 'encodes quotes to html numerically' do
      p = valid_attrs.merge(title: 'what"ever')
      ap = ArtPiece.new(p)
      expect(ap.safe_title).to eq('what&quot;ever')
    end
  end
  describe 'after save' do
    it 'clears representative image cache and new art cache on save' do
      expect(Rails.cache).to receive(:delete).with(CacheKeyService.representative_art(artist)).at_least(1).times
      expect(Rails.cache).to receive(:delete).with(ArtPieceCacheService::NEW_ART_CACHE_KEY)
      art_piece.title = Faker::Lorem.words(number: 2).join(' ')
      art_piece.save
    end
  end
end
