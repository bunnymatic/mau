require 'spec_helper'

describe ArtistGalleryPresenter do

  include PresenterSpecHelpers

  fixtures :users, :roles_users,  :roles, :artist_infos, :art_pieces, :studios, :media, :art_piece_tags, :art_pieces_tags, :cms_documents

  let(:current_page) { 1 }
  let(:per_page) { 2 }
  let(:artists) { Artist.active.all }
  
  subject(:presenter) { ArtistGalleryPresenter.new(mock_view_context, artists, current_page, per_page) }
  
  it 'shows no artists without a representative piece' do
    expect(presenter.items.select{|a| !a.representative_piece}).to be_empty
    expect(presenter.items.select{|a| a.representative_piece}).to have_at_least(1).artist
  end

  describe '.alpha_links' do
    
  end

  

end
