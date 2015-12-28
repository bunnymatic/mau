require 'spec_helper'

describe Favorite, 'named scopes' do

  let(:fan) { FactoryGirl.create(:fan, :active) }
  let!(:jesse) { FactoryGirl.create(:artist, :with_studio, :with_art) }
  let(:anna) { FactoryGirl.create(:artist, :with_studio, :with_art) }
  let(:artist) { FactoryGirl.create(:artist, :with_studio, :with_art) }

  let(:favorite_art_pieces) { Favorite.art_pieces }
  let(:favorite_artists) { Favorite.artists }
  let(:favorite_users) { Favorite.users }
  before do
    fan.add_favorite artist.art_pieces.first
    fan.add_favorite artist
    fan.add_favorite jesse
    jesse.add_favorite artist.art_pieces.first
    jesse.add_favorite artist
    anna.add_favorite jesse.art_pieces.last
  end
  it "users finds only users or artists" do
    expect(favorite_users.count).to be > 0
    favorite_users.all.each do |f|
      expect(f.is_user?).to be_true
      expect(f.is_art_piece?).to be_false
    end
  end
  it "users finds only artists" do
    expect(favorite_artists.count).to be > 0
    favorite_artists.all.each do |f|
      expect(f.is_user?).to be_true
      expect(f.is_artist?).to be_true
      expect(f.is_art_piece?).to be_false
    end
  end
  it "art_pieces finds only art_pieces" do
    expect(favorite_art_pieces.count).to be > 0
    favorite_art_pieces.all.each do |f|
      expect(f.is_user?).to be_false
      expect(f.is_artist?).to be_false
      expect(f.is_art_piece?).to be_true
    end
  end

  it 'destroys unused ones as necessary' do
    f = Favorite.create(:favoritable_type => 'Artist', :favoritable_id => 55555)
    f.to_obj
    expect(Favorite.where(:favoritable_type => 'Artist', :favoritable_id => 55555)).to be_empty
  end


end
