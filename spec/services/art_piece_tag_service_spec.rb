require 'rails_helper'

describe ArtPieceTagService do

  let!(:art_pieces) { create_list :art_piece, 3, :with_tags }
  let!(:tags) { create_list :art_piece_tag, 2 }

  describe '.tags_sorted_by_frequency' do
    it 'returns tags with their count' do
      freq = ArtPieceTagService.tags_sorted_by_frequency
      expect(freq.first.last).to be >= 1
      expect(freq.last).to eql [ArtPieceTag.last, 0.0]
    end
  end

  describe '.delete_unused_tags' do
    it 'removes only tags that are unused' do
      expect {
        ArtPieceTagService.delete_unused_tags
        expect(ArtPieceTagService.tags_sorted_by_frequency.size).to be >= 6
      }.to change(ArtPieceTag, :count).by(-2)
    end
  end

  describe '.destroy' do
    it 'removes the tag' do
      expect {
        ArtPieceTagService.delete_unused_tags
        expect(ArtPieceTagService.tags_sorted_by_frequency.size).to be >= 6
      }.to change(ArtPieceTag, :count).by(-2)
    end
    it 'removes the tag references on any art pieces' do
      tags = ArtPieceTagService.tags_sorted_by_frequency.select{|(tag,ct)| ct > 0}.map(&:first).first(3)
      art_piece = tags.first.art_pieces.first
      expect {
        expect {
          ArtPieceTagService.destroy(tags)
        }.to change(ArtPieceTag, :count).by(-3)
      }.to change(ArtPiecesTag, :count).by(-3)
      expect(art_piece.tags.size).to eq(0)
    end
  end


end
