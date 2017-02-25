# frozen_string_literal: true
require 'rails_helper'
require 'ostruct'

describe ArtPieceImage do
  let(:art_piece) { ArtPiece.new }

  describe '.path' do
    context 'with brand new art piece' do
      it 'returns missing image' do
        expect(ArtPieceImage.new(art_piece).path).to be_nil
      end
    end
  end
end
