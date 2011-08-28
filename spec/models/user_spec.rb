require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

Rails.cache.stubs(:read).returns(:nil)

describe User do
  fixtures :users, :studios, :roles

  describe 'named scope' do
    it "active returns only active users" do
      User.active.all.each do |u|
        u.state.should == 'active'
      end
    end
  end

  describe 'get_profile_image' do
    it 'returns the medium artists profile image if there is one' do
      u = users(:annafizyta)
      u.get_profile_image.should == "/artistdata/#{u.id}/profile/m_profile.jpg"
    end
    it 'returns the small artists profile image if there is one give size = small' do
      u = users(:annafizyta)
      u.get_profile_image(:small).should == "/artistdata/#{u.id}/profile/s_profile.jpg"
    end
  end
  
  describe 'get_share_link' do
    it "returns the artists link" do
      users(:artist1).get_share_link.should match /\/artists\/#{users(:artist1).login}$/
    end
    it "returns the html safe artists link given html_safe = true" do
      users(:artist1).get_share_link(true).should match /%2fartists%2f#{users(:artist1).login}$/i
    end
    it "returns the artists link with params given params" do
      users(:artist1).get_share_link(false, { :this => 'that' }).should match /\/artists\/#{users(:artist1).login}\?this=that$/
    end
  end
  describe 'roles' do
    it "without admin role user is not admin" do
      User.all.first.should_not be_is_admin
    end
    it "without editor role user is not editor" do
      User.all.first.should_not be_is_editor
    end
    it "with admin role, user is admin" do
      u = User.all.first
      u.roles << roles(:admin)
      u.save
      u.reload
      u.should be_is_admin
    end
    it "with editor role, user is editor" do
      u = User.all.first
      u.roles << roles(:editor)
      u.save
      u.reload
      u.should be_is_editor
    end
    it "with editor and admin role, user is both editor and admin" do
      u = User.all.first
      u.roles << roles(:editor)
      u.roles << roles(:admin)
      u.save
      u.reload
      u.should be_is_editor
      u.should be_is_admin
    end
  end
  describe 'auth helpers' do
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

  describe 'address' do
    it "responds to address" do
      users(:artist1).should respond_to :address
    end
    it "responds to full address" do
      users(:artist1).should respond_to :full_address
    end
    it "returns nothing" do
      users(:noaddress).address.should_not be_present
    end
  end
  describe "unavailable methods" do
    it "doesn't reply to old artists attributes" do
      [:lat, :lng, :bio, :street, :city, :zip].each do |method|
        users(:maufan1).should_not respond_to method
      end
    end
  end    
  
  describe 'favorites -'  do
    describe "adding artist as favorite to a user" do
      before do
        @u = users(:maufan1) # he's a fan
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
        @ap = @a.art_pieces.first
      end
      it "favoriting yourself is not allowed" do
        @a.add_favorite(@a).should be_false
      end
      it "favoriting your own art work is not allowed" do
        @a.add_favorite(@ap).should be_false
      end
      it "it doesn't send favorite notification" do
        ArtistMailer.expects('deliver_favorite_notification').never
        @a.add_favorite(@ap).should be_false
      end
    end

    describe "mailer notifications" do
      before do
        @u = users(:maufan1) # he's a fan
        @owner = users(:artist1)
        @ap = @owner.art_pieces.first
      end
      it "add art_piece favorite sends favorite notification to owner" do
        ArtistMailer.expects('deliver_favorite_notification').with(@owner, @u).once
        @u.add_favorite(@ap)
      end
      it "add artist favorite sends favorite notification to user" do
        ArtistMailer.expects('deliver_favorite_notification').with(@owner, @u).once
        @u.add_favorite(@owner)
      end
      it "add artist favorite doesn't send notification to user if user's email settings say no" do
        h = @owner.emailsettings
        h['favorites'] = false
        @owner.emailsettings = h
        @owner.save!
        @owner.reload
        ArtistMailer.expects('deliver_favorite_notification').with(@owner, @u).never
        @u.add_favorite(@owner)
      end
    end    

    describe "adding art_piece as favorite" do
      before do
        @u = users(:maufan1) # he's a fan
        @owner = users(:artist1)
        @ap = @owner.art_pieces.first
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
          f = users(:maufan1).remove_favorite(@ap)
          Favorite.find_all_by_user_id(users(:maufan1).id).should_not include f
        end
        it "user is not in the who favorites me list of the artist who owns that art piece" do
          @u.remove_favorite(@ap)
          @ap.artist.who_favorites_me.should_not include @u
        end
      end
    end
  end

  describe "forgot password methods" do 
    context "artfan" do
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
    context "artist" do
      it "create_reset_code should call mailer" do
        ArtistMailer.expects(:deliver_reset_notification).with() do |f|
          f.login.should == users(:artist1).login
          f.email.should include users(:artist1).email
        end
        users(:artist1).create_reset_code
      end
      it "create_reset_code creates a reset code" do
        users(:artist1).reset_code.should be_nil
        users(:artist1).create_reset_code
        users(:artist1).reset_code.should_not be_nil
      end
    end
  end
  
  describe 'csv_safe' do
    it 'should clean the fields' do
      users(:badname).csv_safe('firstname').should == 'eat123'
    end
  end

  describe 'MailChimp includes' do
    describe "mailchimp_additional_data" do
      before do
        @mail_data = users(:artist1).send(:mailchimp_additional_data)
      end
      it 'returns allowed mapped attributes' do
        expected_keys =  ['FNAME','LNAME', 'CREATED']
        @mail_data.keys.length.should == expected_keys.length
        @mail_data.keys.all?{|k| expected_keys.include? k}.should be
      end
      it 'returns correct values for mapped attributes' do
        @mail_data['CREATED'].should == users(:artist1).activated_at
        @mail_data['FNAME'].should == users(:artist1).firstname
        @mail_data['LNAME'].should == users(:artist1).lastname
      end
    end
    describe 'mailchimp_list_name' do
      it 'returns Mission Artists United List for artists' do
        users(:artist1).send(:mailchimp_list_name).should == MailChimp::ARTISTS_LIST
      end
      it 'returns events only list for fans' do
        users(:maufan1).send(:mailchimp_list_name).should == MailChimp::FANS_LIST
      end
    end
    describe 'subscribe and welcome' do
      before do
        Artist.any_instance.expects(:mailchimp_list_subscribe)
      end
      it "updates mailchimp_subscribed_at column" do
        u = User.first
        mc = u.mailchimp_subscribed_at
        User.first.subscribe_and_welcome
        u.reload
        u.mailchimp_subscribed_at.should_not be_nil
        u.mailchimp_subscribed_at.should be <= Time.now.to_date
      end
    end
  end

  describe "ImageDimensions helper" do
    it "get_scaled_dimensions returns input dimension given user profile with no dimensions" do
      u = users(:maufan1)
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
end
