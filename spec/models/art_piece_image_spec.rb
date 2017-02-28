# frozen_string_literal: true
require 'rails_helper'
require 'ostruct'

describe ArtPieceImage do
  let(:art_piece) { ArtPiece.new }
  subject(:image) { described_class.new(art_piece) }
  describe '.path' do
    context 'with brand new art piece' do
      it 'returns nil' do
        expect(image.path).to be_nil
        expect(ArtPieceImage.new(art_piece).path).to be_nil
      end
    end
    context 'for a piece with an image' do
      let(:art_piece) { build_stubbed(:art_piece) }
      it 'returns the image' do
        expect(image.path).to match %r{system/art_pieces/photos/.*new-art-piece.jpg.*}
      end
    end
  end

  describe '.paths' do
    let(:art_piece) { build_stubbed(:art_piece) }
    it 'shows paths' do
      paths = image.paths
      expect(paths.keys).to match_array(%i(thumb small medium large original))
      expect(paths[:thumb]).to match %r{system/art_pieces/photos/.*/thumb/new-art-piece.jpg.*}
      expect(paths[:small]).to match %r{system/art_pieces/photos/.*/small/new-art-piece.jpg.*}
      expect(paths[:medium]).to match %r{system/art_pieces/photos/.*/medium/new-art-piece.jpg.*}
      expect(paths[:large]).to match %r{system/art_pieces/photos/.*/large/new-art-piece.jpg.*}
      expect(paths[:original]).to match %r{system/art_pieces/photos/.*/original/new-art-piece.jpg.*}
    end
  end
end
