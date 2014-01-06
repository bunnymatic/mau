require 'spec_helper'

describe Favorite, 'named scopes' do
  fixtures :users, :artist_infos, :art_pieces

  let(:fan) { users(:maufan1) }
  let(:jesse) { users(:jesseponce) }
  let(:anna) { users(:annafizyta) }
  let(:artist1) { users(:artist1) }

  let(:favorite_art_pieces) { Favorite.art_pieces }
  let(:favorite_artists) { Favorite.artists }
  let(:favorite_users) { Favorite.users }
  before do
    fan.add_favorite ArtPiece.first
    fan.add_favorite artist1
    fan.add_favorite jesse
    jesse.add_favorite ArtPiece.first
    jesse.add_favorite artist1
    anna.add_favorite ArtPiece.last
  end
  it "users finds only users or artists" do
    favorite_users.count.should > 0
    favorite_users.all.each do |f|
      expect(f.is_user?).to be_true
      expect(f.is_art_piece?).to be_false
    end
  end
  it "users finds only artists" do
    favorite_artists.count.should > 0
    favorite_artists.all.each do |f|
      expect(f.is_user?).to be_true
      expect(f.is_artist?).to be_true
      expect(f.is_art_piece?).to be_false
    end
  end
  it "art_pieces finds only art_pieces" do
    favorite_art_pieces.count.should > 0
    favorite_art_pieces.all.each do |f|
      expect(f.is_user?).to be_false
      expect(f.is_artist?).to be_false
      expect(f.is_art_piece?).to be_true
    end
  end

  it 'destroys unused ones as necessary' do
    f = Favorite.create(:favoritable_type => 'Artist', :favoritable_id => 55555)
    f.to_obj
    Favorite.where(:favoritable_type => 'Artist', :favoritable_id => 55555).should be_empty
  end


end
