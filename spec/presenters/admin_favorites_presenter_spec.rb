require 'spec_helper'

describe AdminFavoritesPresenter do

  fixtures :users, :roles_users, :roles
  fixtures :art_pieces
  fixtures :artist_infos
  fixtures :favorites # even though fixture is empty - this forces a db clear between tests

  let(:art_pieces_per_day) { AdminController.new.send(:compute_art_pieces_per_day) }
  let(:artists_per_day) { AdminController.new.send(:compute_artists_per_day) }
  
  let(:fan) { users(:maufan1) }
  let(:jesse) { users(:jesseponce) }
  let(:anna) { users(:annafizyta) }
  let(:artist) { users(:artist1) }
  let(:art_pieces) { [ArtPiece.first, ArtPiece.last] }
  
  before do
    
    #ArtPiece.any_instance.stub(:artist => double(Artist, :id => 42, :emailsettings => {'favorites' => false}))
    fan.add_favorite art_pieces.first
    fan.add_favorite artist
    fan.add_favorite jesse
    jesse.add_favorite anna
    jesse.add_favorite art_pieces.first
    anna.add_favorite artist
    anna.add_favorite art_pieces.last

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

  it "anna has 1 favorite artist and 1 favorite piece and 1 favorited" do
    annas = @presenter.favorites.detect{|f| f[0] == anna}[1]
    annas.favorited.should eql 1
    annas.artists.should eql 1
    annas.art_pieces.should eql 1
  end
  
end
