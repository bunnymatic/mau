require 'spec_helper'

describe AdminFavoritesPresenter do

  let!(:artist) { FactoryGirl.create(:artist, :active, :with_art) }
  let(:prolific_artist) { FactoryGirl.create(:artist, :active, :with_art, number_of_art_pieces: 15) }

  let(:art_pieces_per_day) { AdminController.new.send(:compute_art_pieces_per_day) }
  let(:artists_per_day) { AdminController.new.send(:compute_artists_per_day) }

  let(:fan) { FactoryGirl.create(:fan, :active) }
  let(:artist2) { FactoryGirl.create(:artist, :active, :with_art) }

  let(:art_pieces) { [ArtPiece.first, ArtPiece.last] }

  before do
    fan.add_favorite artist.art_pieces.first
    fan.add_favorite artist
    fan.add_favorite artist2
    artist2.add_favorite artist
    artist2.add_favorite artist

    @presenter = AdminFavoritesPresenter.new Favorite.all
  end

  it "assigns :favorites to a hash keyed by user login" do
    @presenter.favorites.count.should be > 0
    @presenter.favorites.first.first.should be_a_kind_of User
  end

  it "fan should have 1 favorite art piece" do
    @presenter.favorites.detect{|f| f[0] == fan}[1].art_pieces.should eql 1
  end

  it "fan should have 2 favorite artists" do
    @presenter.favorites.detect{|f| f[0] == fan}[1].artists.should eql 2
  end

  it "artist should have 2 favorited" do
    @presenter.favorites.detect{|f| f[0] == artist}[1].favorited.should eql 2
  end

end
