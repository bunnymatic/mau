require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

Rails.cache.stubs(:read).returns(:nil)

describe User, 'named scope' do
  it "active returns only active users" do
    User.active.all.each do |u|
      u.state.should == 'active'
    end
  end
end
describe User, 'auth helpers' do
  describe "make token " do
    before do
      @token = User.make_token
    end
    it "returns a string greater than 20 chars" do
      @token.length.should > 20
    end
    it "returns a string with only numbers and letters" do
      @token.should_not match /\W+/
    end
    it "when called again returns something different" do
      @token.should_not eql User.make_token
    end
  end
end

describe User, 'address' do
  fixtures :users, :artist_infos, :studios
  it "responds to address" do
    users(:artist1).should respond_to :address
  end
  it "responds to full address" do
    users(:artist1).should respond_to :full_address
  end
  it "returns nothing" do
    users(:artist1).address.should_not be
  end
  it "returns address after adding artist info address" do
    aid = users(:artist1).id
    ai = artist_infos(:wayout)
    ai.artist_id = aid
    ai.save
    users(:artist1).address.should include ai.street
  end
  it "returns studio address after adding studio" do
    u = users(:artist1)
    u.studio = studios(:s1890)
    u.save
    users(:artist1).address.should include studios(:s1890).street
  end
  it "returns studio address after adding both studio and address" do
    u = users(:artist1)
    u.studio = studios(:s1890)
    u.save
    aid = u.id
    ai = artist_infos(:wayout)
    ai.artist_id = aid
    ai.save
    users(:artist1).address.should include studios(:s1890).street
  end
end

describe User, "unavailable methods" do
  fixtures :users
  it "doesn't reply to old artists attributes" do
    pending "we need to remove these fields from user when shit is working"
    [:lat, :lng, :bio, :street, :city, :zip].each do |method|
      users(:aaron).should_not respond_to method
    end
  end
end    
    
describe User, 'favorites -'  do
  fixtures :users, :art_pieces

  describe "adding artist as favorite to a user" do
    before do
      @u = users(:aaron) # he's a fan
      @a = users(:artist1) 
      @u.add_favorite(@a)
      @u.save
    end
    it "all users favorites should be either of type Artist or ArtPiece" do
      @u.favorites.select {|f| ['Artist','ArtPiece'].include? f.favoritable_type}.should have_at_least(1).favorite
    end
    it "artist is in the users favorites list" do
      favs = @u.favorites.select { |f| f.favoritable_id == @a.id }
      favs.should have(1).artist
      favs[0].favoritable_id.should eql(@a.id)
      favs[0].favoritable_type.should eql('Artist')
    end
    it "artist is in the users favorite.to_obj list as an artist model" do
      fs = @u.favorites.to_obj.select { |f| f.id == @a.id }
      fs.should have(1).artist
      fs[0].id.should == @a.id
      fs[0].class.should == Artist
    end
    it "artist is in user.fav_artists list" do
      (@u.fav_artists.map { |a| a.id }).should include(@a.id)
    end
    it "first in user.fav_artists list is an Artist" do
      @u.fav_artists.first.is_a?(User).should be
    end
    it ", that user is in the artists' who favorites me list" do
      @a.who_favorites_me.should include @u
    end
    context "and removing that artist" do
      before do
        @u.remove_favorite(@a)
      end
      it ", artist is no longer a favorite" do
        @u.fav_art_pieces.should have(0).artists
      end
      it ", that user no longer in the artists' who favorites me list" do
        @a.who_favorites_me.should_not include @u
      end
    end
    context "and trying to add a duplicate artist" do
      before do
        @num_favs = @u.favorites.count
        @result = @u.add_favorite(@a)
      end
      it "doesn't add" do
        @result.should be_false
        @num_favs.should == @u.favorites.count
      end
    end
    context "then artist deactivates" do
      before do
        @aid = @a.id
        @favs = @u.favorites.count
        @a.destroy
      end
      it "fav_artists should not return deactivated artist" do
        (@u.fav_artists.map { |a| a.id }).should_not include(@aid)
      end
      it "favorites list should be smaller" do
        @u.favorites.count.should == @favs - 1
      end
    end
  end
  describe "narcissism" do
    before do
      @a = users(:artist1)
      @ap = art_pieces(:hot)
      @ap.artist = @a
      @ap.save
    end
    it "favoriting yourself is not allowed" do
      @a.add_favorite(@a).should be_false
    end
    it "favoriting your own art work is not allowed" do
      @a.add_favorite(@ap).should be_false
    end
  end
      
  describe "adding art_piece as favorite" do
    before do
      @u = users(:aaron) # he's a fan
      @ap = art_pieces(:hot)
      @owner = users(:artist1)
      @ap.artist = @owner
      @ap.save
      @u.add_favorite(@ap)
    end
    it "all users favorites should be either of type Artist or ArtPiece" do
      @u.favorites.select {|f| ['Artist','ArtPiece'].include? f.favoritable_type}.should have_at_least(1).favorite
    end
    it "art_piece is in favorites list" do
      fs = @u.favorites.select { |f| f.favoritable_id == @ap.id }
      fs.should have(1).art_piece
      fs[0].favoritable_id.should == @ap.id
      fs[0].favoritable_type.should == 'ArtPiece'
    end
    it "art_piece is in favorites_to_obj list as an ArtPiece" do
      fs = @u.favorites.to_obj.select { |f| f.id == @ap.id }
      fs.should have(1).art_piece
      fs[0].id.should == @ap.id
      fs[0].class.should == ArtPiece
    end

    it "art_piece is in the artists 'fav_art_pieces' list" do
      (@u.fav_art_pieces.map { |ap| ap.id }).should include(@ap.id)
    end
    it "art piece is of type ArtPiece" do 
      @u.fav_art_pieces.first.is_a?(ArtPiece).should be
    end
    it "user does not have 'art_pieces' because he's a user" do
      @u.methods.should_not include('art_pieces')
    end

    context "and trying to add it again" do
      before do
        @num_favs = @u.favorites.count
        @result = @u.add_favorite(@ap)
      end
      it "doesn't add" do
        @result.should be_false
        @num_favs.should == @u.favorites.count
      end
    end
    
    context " and removing it" do
      it "Favorite delete get's called" do
        f = Favorite.find_by_favoritable_id_and_favoritable_type_and_user_id(@ap.id, @ap.class.name, @u.id)
        Favorite.any_instance.expects(:destroy).times(1)
        @u.remove_favorite(@ap)
      end
      it "art_piece is no longer a favorite" do
        f = users(:aaron).remove_favorite(@ap)
        Favorite.find_all_by_user_id(users(:aaron).id).should_not include f
      end
      it "user is not in the who favorites me list of the artist who owns that art piece" do
        @u.remove_favorite(@ap)
        @ap.artist.who_favorites_me.should_not include @u
      end
    end
  end
end

describe User, "forgot password methods" do 
  fixtures :users
  it "create_reset_code should call mailer" do
    UserMailer.expects(:deliver_reset_notification).with() do |f|
            f.login.should == users(:artfan).login
            f.email.should include users(:artfan).email
    end
    users(:artfan).create_reset_code
  end
  it "create_reset_code creates a reset code" do
    users(:artfan).reset_code.should be_nil
    users(:artfan).create_reset_code
    users(:artfan).reset_code.should_not be_nil
  end
end

describe User, "ImageDimensions helper" do
  fixtures :users
  it "get_scaled_dimensions returns input dimension given user profile with no dimensions" do
    u = users(:aaron)
    u.get_scaled_dimensions(100).should == [100,100]
  end
  it "get_scaled_dimensions returns the max of the dim given user profile with dimensions" do
    u = users(:joeblogs)
    u.get_scaled_dimensions(1000).should == [1000,333]
  end
  it "get_min_scaled_dimensions returns the max of the dim given art with dimensions" do
    u = users(:joeblogs)
    u.get_min_scaled_dimensions(11).should == [33,11]
  end
end
    
