require 'spec_helper'

describe ArtPiecesController do

  fixtures :users, :artist_infos, :cms_documents, :studios, :art_pieces, :roles_users, :roles
  before do
    pretend_to_be_mobile
  end

  describe '#show' do
    it 'redirects to artist page' do
      get :show, :id => ArtPiece.first
      expect(response).to redirect_to ArtPiece.first.artist
    end
  end
end
