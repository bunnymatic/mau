require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Favorite, 'named scopes' do
  fixtures :favorites

  it "users finds only users or artists" do 
    Favorite.users.all.each do |f|
      ['Artist','User'].should include f.favoritable_type
      ['ArtPiece'].should_not include f.favoritable_type
    end
  end
  it "art_pieces finds only art_pieces" do
    Favorite.art_pieces.all.each do |f|
      ['Artist','User'].should_not include f.favoritable_type
      ['ArtPiece'].should include f.favoritable_type
    end
  end

end
