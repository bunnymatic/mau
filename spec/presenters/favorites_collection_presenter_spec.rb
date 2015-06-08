require 'spec_helper'

describe FavoritesCollectionPresenter do
  let(:artists) { create_list(:artist, 4, :active, :with_art) + [create(:artist, :active)] }
  let(:artist) { artists.first }
  let(:current_user) { nil }
  subject(:presenter) { FavoritesCollectionPresenter.new(artist.favorites, artist, current_user) }

  context 'with favorites' do
    before do
      artist.add_favorite(artists[1])
      artist.add_favorite(artists[2])
      artist.add_favorite(artists.last)

      artist.add_favorite(artists[2].art_pieces.first)
      artist.add_favorite(artists[3].art_pieces.first)
    end

    its(:art_pieces) { should have(2).art_pieces }
    its(:artists) { should have(2).artists }

    context 'when the artists are not all active' do
      before do
        artists[1].suspend!
      end
      its(:artists) { should have(1).artists }
    end


  end

  context 'when the artist has no favorites' do
    its(:art_pieces) { should be_empty }
    its(:artists) { should be_empty }
    its(:empty_message) { should match /not favorited anything/ }
  end

  context 'when the viewer is the artist' do
    let(:current_user) { artist }
    context 'and the artist has no favorites' do
      its(:empty_message) { should match /Go find an artist/ }
    end
  end

end
