require 'spec_helper'

describe ArtPiecesController do

  fixtures :users, :artist_infos, :cms_documents, :studios
  before do
    # do mobile
    request.stub(:user_agent => IPHONE_USER_AGENT)
  end

  describe '#show' do
    it 'redirects to artist page' do
      get :show, :id => ArtPiece.first.id
      response.should redirect_to ArtPiece.first.artist
    end
  end
end
