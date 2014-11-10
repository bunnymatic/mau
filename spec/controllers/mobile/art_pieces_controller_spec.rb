require 'spec_helper'

describe ArtPiecesController do

  let(:artist) { FactoryGirl.create(:artist, :with_art) }
  let(:art_piece) { artist.art_pieces.first }

  before do
    pretend_to_be_mobile
  end

  describe '#show' do
    it 'redirects to artist page' do
      get :show, :id => art_piece
      expect(response).to redirect_to artist
    end
  end
end
