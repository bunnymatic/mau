require 'rails_helper'

describe AdminFavoritesPresenter do
  let!(:artist) { FactoryBot.create(:artist, :active, :with_art) }
  let(:prolific_artist) { FactoryBot.create(:artist, :active, :with_art, number_of_art_pieces: 15) }

  let(:art_pieces_per_day) { AdminController.new.send(:compute_art_pieces_per_day) }
  let(:artists_per_day) { AdminController.new.send(:compute_artists_per_day) }

  let(:fan) { FactoryBot.create(:fan, :active) }
  let(:artist2) { FactoryBot.create(:artist, :active, :with_art) }

  let(:art_pieces) { [ArtPiece.first, ArtPiece.last] }

  before do
    create_favorite fan, artist.art_pieces.first
    create_favorite fan, artist
    create_favorite fan, artist2
    create_favorite artist2, artist
    create_favorite artist2, artist

    @presenter = AdminFavoritesPresenter.new Favorite.all
  end

  it 'assigns :favorites to a hash keyed by user login' do
    expect(@presenter.favorites.count).to be > 0
    expect(@presenter.favorites.first.first).to be_a_kind_of User
  end

  it 'fan should have 1 favorite art piece' do
    expect(@presenter.favorites.detect { |f| f[0] == fan }[1].art_pieces).to eql 1
  end

  it 'fan should have 2 favorite artists' do
    expect(@presenter.favorites.detect { |f| f[0] == fan }[1].artists).to eql 2
  end

  it 'artist should have 2 favorited' do
    expect(@presenter.favorites.detect { |f| f[0] == artist }[1].favorited).to eql 2
  end

  describe 'totals' do
    it 'total_artists' do
      expect(@presenter.total_artists).to eq 3
    end
    it 'total_art_pieces' do
      expect(@presenter.total_art_pieces).to eq 1
    end
    it 'total_favorited_users' do
      expect(@presenter.total_favorited_users).to eq 3
    end
  end
end
