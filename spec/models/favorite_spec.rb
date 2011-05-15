require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Favorite, 'named scopes' do
  fixtures :users, :artist_infos, :art_pieces
  before do
    u1 = users(:maufan1)
    u2 = users(:jesseponce)
    u3 = users(:annafizyta)
    
    artist = users(:artist1)
    artist.artist_info = artist_infos(:artist1)
    artist.save
    
    a1 = ArtPiece.first
    a1.artist = artist
    a1.save
    a2 = ArtPiece.last
    a2.artist = artist
    a2.save
    
    ArtPiece.any_instance.stubs(:artist => stub(:id => 42, :emailsettings => {'favorites' => false}))
    u1.add_favorite a1
    u1.add_favorite users(:artist1)
    u1.add_favorite u2
    u2.add_favorite a1
    u2.add_favorite users(:artist1)
    u3.add_favorite a2
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

end
