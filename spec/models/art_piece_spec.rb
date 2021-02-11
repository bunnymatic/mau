# frozen_string_literal: true

require 'rails_helper'

describe ArtPiece do
  let(:valid_attrs) { FactoryBot.attributes_for(:art_piece) }
  let(:artist) { FactoryBot.create(:artist, :active, :with_art) }
  let(:art_piece) { artist.art_pieces.first }

  it { should validate_presence_of(:title) }
  it { should validate_length_of(:title).is_at_least(2).is_at_most(80) }
  it { should validate_numericality_of(:price).allow_nil.is_greater_than_or_equal_to(0.01) }

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

  describe 'get_name' do
    it 'allows escaping' do
      ap = FactoryBot.build(:art_piece, title: "\"Hey\" That's Joe's")
      escaped = ap.get_name(escape: true)
      expect(escaped).to eq(HtmlEncoder.encode(ap.get_name))
    end
  end

  describe 'sold' do
    it 'sets sold_at to now if sold = "1" when you save' do
      freeze_time do
        now = Time.current
        art_piece.sold = '1'
        art_piece.save
        art_piece.reload
        expect(art_piece.sold_at).to eq now
      end
    end

    it 'sets sold_at to nil if it was set and then sold is marked false' do
      art_piece.update({ sold_at: Time.current })
      art_piece.sold = false
      art_piece.save
      art_piece.reload
      expect(art_piece.sold_at).to be_nil
    end

    it 'sets sold_at to nil if sold is not "1"' do
      art_piece.update({ sold_at: Time.current })
      art_piece.sold = '0'
      art_piece.save
      art_piece.reload
      expect(art_piece.sold_at).to be_nil
    end
  end
end
