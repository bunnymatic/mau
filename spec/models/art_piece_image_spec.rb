require 'spec_helper'
require 'ostruct'

describe ArtPieceImage do
  let(:art_piece) { ArtPiece.new }

  describe '.path' do
    context 'with brand new art piece' do
      it 'returns missing image' do
        ArtPieceImage.new(art_piece).path.should be_nil
      end
    end
  end
end
