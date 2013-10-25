require 'spec_helper'

describe Favorite, 'named scopes' do
  fixtures :users, :artist_infos, :art_pieces
  before do
    u1 = users(:maufan1)
    u2 = users(:jesseponce)
    u3 = users(:annafizyta)

    ArtPiece.any_instance.stub(:artist => double(Artist, :id => 42, :emailsettings => {'favorites' => false}))
    u1.add_favorite ArtPiece.first
    u1.add_favorite users(:artist1)
    u1.add_favorite u2
    u2.add_favorite ArtPiece.first
    u2.add_favorite users(:artist1)
    u3.add_favorite ArtPiece.last
  end
  it "users finds only users or artists" do
    Favorite.users.count.should > 0
    Favorite.users.all.each do |f|
      ['Artist','User'].should include f.favoritable_type
      ['ArtPiece'].should_not include f.favoritable_type
    end
  end
  it "art_pieces finds only art_pieces" do
    Favorite.art_pieces.count.should > 0
    Favorite.art_pieces.all.each do |f|
      ['Artist','User'].should_not include f.favoritable_type
      ['ArtPiece'].should include f.favoritable_type
    end
  end

  it 'destroys unused ones as necessary' do
    f = Favorite.create(:favoritable_type => 'Artist', :favoritable_id => 55555)
    f.to_obj
    Favorite.where(:favoritable_type => 'Artist', :favoritable_id => 55555).should be_empty
  end


end
