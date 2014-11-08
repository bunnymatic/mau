require 'spec_helper'

shared_examples_for 'common signup form' do
  it_should_behave_like 'one column layout'
  it "has signup form with captcha and options for fan and artist" do
    assert_select("#signup_form")
    assert_select('textarea[name=recaptcha_challenge_field]')
    assert_select 'select option[value=Artist]'
    assert_select 'select option[value=MAUFan]'
  end

end

describe UsersController do

  let(:fan) { FactoryGirl.create(:fan) }
  let(:quentin) { FactoryGirl.create :artist }
  let(:admin) { FactoryGirl.create :user, :admin, :active }
  let(:jesse) { quentin }
  let(:joe) { FactoryGirl.create :artist, :active }
  let(:artist) { FactoryGirl.create :artist, :active }
  let(:pending) { FactoryGirl.create :artist, :pending }
  let(:pending_fan) { FactoryGirl.create :fan, :pending }
  let(:art_pieces) do
    FactoryGirl.create_list :art_piece, 4, :with_tag, artist: artist
  end
  let(:art_piece) do
    art_pieces.first
  end

  let(:scammer) { FactoryGirl.create :scammer }

  before do
    ####
    # stub mailchimp calls
    stub_signup_notification
    stub_mailchimp
  end

  it "actions should fail if not logged in" do
    exceptions = [:index, :show, :update, :artists, :resend_activation, :favorites,
                  :forgot, :destroy, :create, :new, :activate,
                  :notify, :noteform, :reset, :favorites_notify]
    controller_actions_should_fail_if_not_logged_in(:user,
                                                    :except => exceptions)
  end

  describe '#index' do
    it { get :index; expect(response).to redirect_to artists_path }
  end

  describe "#new" do
    context 'already logged in' do
      before do
        login_as fan
        get :new
      end
      it 'redirects to your page' do
        expect(response).to redirect_to root_path
      end
    end
    context 'not logged in' do
      render_views

      context 'with no type' do
        before do
          # disable sweep of flash.now messages
          # so we can test them
          @controller.instance_eval{flash.stub(:sweep)}
          get :new
        end
        it_should_behave_like 'common signup form'
        it "has first & last name text boxes" do
          assert_select("#artist_firstname")
          assert_select("#artist_lastname")
        end
      end

      context 'with type = artist' do
        before do
          # disable sweep of flash.now messages
          # so we can test them
          @controller.instance_eval{flash.stub(:sweep)}
          get :new, :type => 'Artist'
        end
        it_should_behave_like 'common signup form'
        it "has first and last name text boxes" do
          assert_select("#artist_firstname")
          assert_select("#artist_lastname")
        end
      end

      context 'with no type' do
        before do
          # disable sweep of flash.now messages
          # so we can test them
          @controller.instance_eval{flash.stub(:sweep)}
          get :new, :type => 'MAUFan'
        end
        it_should_behave_like 'common signup form'
        it "has a first and last name text boxes" do
          assert_select("#mau_fan_firstname")
          assert_select("#mau_fan_lastname")
        end
      end
    end
  end

  describe "#create", :eventmachine => true do
    context 'with blacklisted domain' do
      before do
        # disable sweep of flash.now messages
        # so we can test them
        FactoryGirl.create(:blacklist_domain, domain: 'blacklist.com')
        @controller.instance_eval{flash.stub(:sweep)}
        @controller.should_receive(:verify_recaptcha).and_return(true)
      end
      it 'forbids email whose domain is on the blacklist' do
        expect {
          post :create, :mau_fan => { :login => 'newuser',
            :password_confirmation => "blurpit",
            :lastname => "bmatic2",
            :firstname => "bmatic2",
            :password => "blurpit",
            :email => "bmatic2@blacklist.com" }, :type => "MAUFan" }.to change(User,:count).by(0)
      end
      it 'allows non blacklist domain to add a user' do
        expect {
          post :create, :mau_fan => { :login => 'newuser',
            :password_confirmation => "blurpit",
            :lastname => "bmatic2",
            :firstname => "bmatic2",
            :password => "blurpit",
            :email => "bmatic2@nonblacklist.com" }, :type => "MAUFan" }.to change(User,:count).by(1)
      end
    end
    context "with invalid recaptcha" do
      before do
        # disable sweep of flash.now messages
        # so we can test them
        @controller.instance_eval{flash.stub(:sweep)}
        @controller.should_receive(:verify_recaptcha).and_return(false)
        post :create, :mau_fan => { :login => 'newuser',
          :password_confirmation => "blurpit",
          :lastname => "bmatic2",
          :firstname => "bmatic2",
          :password => "blurpit",
          :email => "bmatic2@b.com" }, :type => "MAUFan"
      end
      it "returns success" do
        expect(response).to be_success
      end

      it "sets a flash.now indicating failure" do
        flash.now[:error].should include 'human'
      end
    end

    context "with partial params" do
      before do
        # disable sweep of flash.now messages
        # so we can test them
        @controller.instance_eval{flash.stub(:sweep)}
      end
      context "login = 'newuser'" do
        before do
          post :create, :user => { :login => 'newuser' }, :type => "MAUFan"
        end

        it "login=>newuser : should return success" do
          expect(response).to be_success
        end

        it "sets a flash.now indicating failure" do
          post :create, :user => { :login => 'newuser' }, :type => "MAUFan"
        end
      end
    end
    context "valid user params and type = MAUFan" do
      before do
        MAUFan.any_instance.should_receive(:subscribe_and_welcome)
        UserMailer.should_receive(:activation).exactly(:once).and_return(double(:deliver! => true))
        post :create, :mau_fan => { :login => 'newuser',
          :password_confirmation => "blurpit",
          :lastname => "bmatic2",
          :firstname => "bmatic2",
          :password => "blurpit",
          :email => "bmatic2@b.com" }, :type => "MAUFan"
      end
      it "redirects to index" do
        expect(response).to redirect_to( login_url )
      end
      it "sets flash indicating that activation email has been sent" do
        flash[:notice].should include(" ready to roll")
      end
      context "creates an account" do
        before do
          @found_user = User.find_by_login("newuser")
        end
        it "in the user database" do
          @found_user.should be
        end
        it "whose state is 'active'" do
          @found_user.state.should be == 'active'
        end
        it "whose type is 'MAUFan'" do
          @found_user.type == 'MAUFan'
        end
      end
      it "should register as a fan account" do
        MAUFan.find_by_login("newuser").should be
      end
      it "should not register as an artist account" do
        Artist.find_by_login("newuser").should be_nil
      end
      it "should register as user account" do
        User.find_by_login("newuser").should be
      end
    end
    context "valid user param (email/password only) and type = MAUFan" do
      before do
        MAUFan.any_instance.should_receive(:subscribe_and_welcome)
        post :create, :mau_fan => {
          :password_confirmation => "blurpit",
          :password => "blurpit",
          :email => "bmati2@b.com" }, :type => "MAUFan"
      end
      it "redirects to index" do
        expect(response).to redirect_to( login_url )
      end
      it "sets flash indicating that activation email has been sent" do
        flash[:notice].should include(" ready to roll")
      end
      context "creates an account" do

        before do
          @found_user = User.find_by_login("bmati2@b.com")
        end
        it "in the user database" do
          @found_user.should be
        end
        it "whose state is 'active'" do
          @found_user.state.should be == 'active'
        end
        it "whose type is 'MAUFan'" do
          @found_user.type == 'MAUFan'
        end
      end
      it "should register as a fan account" do
        MAUFan.find_by_login("bmati2@b.com").should be
      end
      it "should not register as an artist account" do
        Artist.find_by_login("bmati2@b.com").should be_nil
      end
      it "should register as user account" do
        User.find_by_login("bmati2@b.com").should be
      end
    end
    context "valid artist params and type = Artist" do
      before do
        Artist.any_instance.stub(:activation_code => 'random_activation_code')
        Artist.any_instance.should_receive(:make_activation_code).at_least(1)
        MAUFan.any_instance.should_receive(:subscribe_and_welcome).never
        post :create, :artist => { :login => 'newuser2',
          :password_confirmation => "blurpt",
          :lastname => "bmatic",
          :firstname => "bmatic",
          :password => "blurpt",
          :email => "bmatic2@b.com" }, :type => "Artist"
      end
      it "redirects to index" do
        expect(response).to redirect_to( root_url )
      end
      it "sets flash indicating that activation email has been sent" do
        flash[:notice].should include(" email with your activation code")
      end
      context "creates an account" do
        before do
          @found_artist = User.find_by_login("newuser2")
        end
        it "in the artist database" do
          @found_artist.should be
        end
        it "whose state is 'pending'" do
          @found_artist.state.should eql 'pending'
        end
        it "whose type is 'Artist'" do
          @found_artist.type.should eql 'Artist'
        end
        it "has an associated artist_info" do
          @found_artist.artist_info.should_not be_nil
        end
      end
      it "should not register as a fan account" do
        MAUFan.find_by_login("newuser2").should be_nil
      end
    end
  end

  describe "#show" do
    render_views
    context "while not logged in" do
      before do
        get :show, :id => 123
      end
      it_should_behave_like "not logged in"
    end
    context 'looking for an invalid user id' do
      before do
        get :show, :id => 'eat it'
      end
      it 'flashes an error' do
        expect(flash.now[:error]).to include 'not found'
      end
    end
    context 'looking for an artist' do
      before do
        get :show, :id => artist.id
      end
      it { expect(response).to redirect_to artist_path(artist) }
    end
    context "getting a users page while not logged in" do
      before do
        get :show, :id => fan.id
      end
      it_should_behave_like 'two column layout'
      it { expect(response).to be_success }
      it "has the users name on it" do
        assert_select '#artist_profile_name h4', :text => "#{fan.firstname} #{fan.lastname}"
      end
      it "has a profile image" do
        assert_select "img.profile"
      end
      it "shows the users website" do
        assert_select "#u_website a[href=#{fan.url}]"
      end
    end
    context "while logged in as an user" do
      before do
        login_as(fan)
        @logged_in_user = fan
        get :show, :id => fan.id
      end
      it_should_behave_like 'two column layout'
      it_should_behave_like "logged in user"
      it "has sidebar nav when i look at my page" do
        assert_select('#sidebar_nav')
      end
      it "has no sidebar nav when i look at someone elses page" do
        get :show, :id => artist
        css_select('#sidebar_nav').should be_empty
      end
    end
  end
  describe "#edit" do
    context "while not logged in" do
      render_views
      before do
        get :edit
      end
      it_should_behave_like "redirects to login"
    end
    context "while logged in as an artist" do
      before do
        login_as(artist)
        get :edit
      end
      it "GET should redirect to artist edit" do
        expect(response).to be_redirect
      end
      it "renders the edit template" do
        expect(response).to redirect_to edit_artist_url(artist)
      end
    end
    context "while logged in as an user" do
      render_views
      before do
        login_as(fan)
        get :edit, :id => fan.id
      end

      it_should_behave_like 'one column layout'
      it_should_behave_like "logged in edit page"

      it { expect(response).to be_success }
      it "renders the user edit template" do
        expect(response).to render_template("edit")
      end
      it "has no heart notification checkbox" do
        css_select( "#notifications input#emailsettings_favorites").should be_empty
      end
    end
  end

  describe "login_required" do
    context " post redirects to root (referrer)" do
      before do
        post :add_favorite
      end
      it "add_favorite requires login" do
        expect(response).to redirect_to( new_user_session_path )
      end
      it "auth system should try to record referrer" do
        request.session[:return_to].should eql SHARED_REFERER
      end
    end
    context "get redirects to requested page via login" do
      before do
        get :edit
      end
      it "add_favorite requires login" do
        expect(response).to redirect_to( new_user_session_path )
      end
      it "auth system should try to record referrer" do
        request.session[:return_to].should eql "/users/edit"
      end
    end
  end
  describe "#update" do
    context "while not logged in" do
      context "with invalid params" do
        before do
          put :update, :id => quentin.id, :user => {}
        end
        it_should_behave_like "redirects to login"
      end
      context "with valid params" do
        before do
          put :update, :id => quentin.id, :user => { :firstname => 'blow' }
        end
        it_should_behave_like "redirects to login"
      end
    end
    context "while logged in" do
      before do
        login_as(quentin, :record => true)
        @logged_in_user = quentin
      end
      context "with empty params" do
        before do
          put :update, :id => quentin.id, :user => {}
        end
        it "redirects to user edit page" do
          expect(response).to redirect_to(edit_user_path(quentin))
        end
        it "contains flash notice of success" do
          flash[:notice].should eql "Update successful"
        end
      end
      context "with valid and a cancel" do
        before do
          put :update, :id => quentin.id, :user => { :firstname => 'blow' }, :commit => 'Cancel'
        end
        it { expect(response).to redirect_to(user_path(quentin)) }
      end
      context "with valid params" do
        before do
          put :update, :id => quentin.id, :user => {:firstname => 'blow'}
        end
        it "redirects to user edit page" do
          expect(response).to redirect_to(edit_user_path(quentin))
        end
        it "contains flash notice of success" do
          flash[:notice].should eql "Update successful"
        end
        it "updates user attributes" do
          User.find(quentin.id).firstname.should eql "blow"
        end
      end
    end
  end

  describe "favorites" do
    render_views
    context "show" do
      context "while not logged in" do
        before do
          get :favorites, :id => fan.id
        end
        it_should_behave_like 'one column layout'
        it { expect(response).to be_success }
        it "doesn't have the no favorites msg" do
          css_select('.no-favorites-msg').should be_empty
        end
      end
      context "asking for a user that doesn't exist" do
        before do
          get :favorites, :id => 'bogus'
        end
        it "redirects to root" do
          expect(response).to redirect_to root_path
        end
        it "flashes an error" do
          flash[:error].should be_present
        end
      end
      context "while logged in as fan with no favorites" do
        let(:artist) { FactoryGirl.create(:artist) }
        before do
          ArtPiece.any_instance.stub(:artist => artist)
          login_as(fan)
          get :favorites, :id => fan.id
        end
        it_should_behave_like 'one column layout'
        it { expect(response).to be_success }
        it "gets some random links assigned" do
          assigns(:random_picks).size.should > 2
        end
        it "has the no favorites msg" do
          assert_select('.no-favorites-msg', :count => 1)
        end
        it "has section for 'artist by name'" do
          assert_select('.by-name h5', :text => 'Find Artists by Name')
        end
        it "has section for 'artist by medium'" do
          assert_select('.by-medium h5', :text => 'Find Artists by Medium')
        end
        it "has section for 'artist by tag'" do
          assert_select('.by-tag h5', :text => 'Find Artists by Tag')
        end
        it "does not show the favorites sections" do
          css_select('.favorites > h5').should be_empty
          css_select('.favorites > h5').should be_empty
        end
        it "doesn't show a button back to the artists page" do
          css_select('.buttons form').should be_empty
        end
      end
      context "while logged in as artist" do
        before do
          ArtPiece.any_instance.stub(:artist => quentin)
          login_as(artist)
        end
        it 'returns success' do
          get :favorites, :id => artist.id
          expect(response).to be_success
        end
        context "who has favorites" do
          before do
            User.any_instance.stub(:get_profile_path => "/this")
            ArtPiece.any_instance.stub(:get_path).with('small').and_return("/this")
            ap = FactoryGirl.create(:art_piece, artist: joe)
            artist.add_favorite ap
            artist.add_favorite joe
            assert artist.favorites.count >= 1
            assert artist.fav_artists.count >= 1
            assert artist.fav_art_pieces.count >= 1
            get :favorites, :id => artist.id
          end
          it_should_behave_like 'one column layout'
          it { expect(response).to be_success }
          it "does not assign random picks" do
            assigns(:random_picks).should be_nil
          end
          it "shows the title" do
            assert_select('h4', :match => 'My Favorites')
          end
          it "favorites sections show and include the count" do
            assert_select('h5', :text => "Artists (#{artist.fav_artists.count})")
            assert_select("h5", :text => "Art Pieces (#{artist.fav_art_pieces.count})")
          end
          it "shows the 1 art piece favorite" do
            assert_select('.favorites .art_pieces .thumb', :count => 1, :include => 'by blupr')
          end
          it "shows the 1 artist favorite" do
            assert_select('.favorites .artists .thumb', :count => 1)
          end
          it "shows a delete button for each favorite" do
            assert_select('.favorites li .trash', :count => artist.favorites.count)
          end
          it "shows a button back to the artists page" do
            assert_select('.buttons form')
          end
        end
      end
      context "logged in as user looking at artist who has favorites " do
        before do
          User.any_instance.stub(:get_profile_path => "/this")
          ArtPiece.any_instance.stub(:get_path).with('small').and_return("/this")
          FactoryGirl.create(:art_piece, artist: joe)
          artist.add_favorite joe
          artist.add_favorite joe.art_pieces.last
          assert artist.fav_artists.count >= 1
          assert artist.fav_art_pieces.count >= 1
          login_as fan
          get :favorites, :id => artist.id
        end
        it_should_behave_like 'one column layout'
        it { expect(response).to be_success }
        it "shows the title" do
          assert_select('h4', :include => artist.get_name )
          assert_select('h4', :include => 'Favorites')
        end
        it "shows the favorites sections" do
          assert_select('h5', :include => 'Artists')
          assert_select('h5', :include => 'Art Pieces')
        end
        it "shows the 1 art piece favorite" do
          assert_select('.favorites .art_pieces .thumb', :count => 1)
        end
        it "shows the 1 artist favorite" do
          assert_select('.favorites .artists .thumb', :count => 1)
        end
        it "does not show a delete button for each favorite" do
          css_select('.favorites li .trash').should be_empty
        end
      end
    end
    context "POST favorites" do
      context "requesting anything but a post" do
        it "redirects to login" do
          put :add_favorite
          expect(response).to redirect_to(new_user_session_path)
          delete :add_favorite
          expect(response).to redirect_to(new_user_session_path)
          get :add_favorite
          expect(response).to redirect_to(new_user_session_path)
        end
      end
      context "while not logged in" do
        describe "post to add favorites" do
          before do
            post :add_favorite
          end
          it_should_behave_like "redirects to login"
        end
        describe "post remove_favorites" do
          before do
            post :remove_favorite
          end
          it_should_behave_like "redirects to login"
        end
      end
      context "while logged in" do
        before do
          login_as(quentin)
          @ap = art_piece
          @ap.artist = artist
          @ap.save.should be_true
        end
        context "add a favorite artist" do
          before do
            post :add_favorite, :fav_type => 'Artist', :fav_id => artist.id
          end
          it "returns success" do
            expect(response).to redirect_to(artist_path(artist))
          end
          it "adds favorite to user" do
            u = User.find(quentin.id)
            favs = u.favorites
            favs.map { |f| f.favoritable_id }.should include artist.id
          end
          context "then remove that artist from favorites" do
            before do
              post :remove_favorite, :fav_type => "Artist", :fav_id => artist.id
            end
            it "redirects to the referer" do
              expect(response).to redirect_to( SHARED_REFERER )
            end
            it "that artist is no longer a favorite" do
              u = User.find(quentin.id)
              favs = u.favorites
              favs.map { |f| f.favoritable_id }.should_not include artist.id
            end
          end
        end
        context "add a favorite art_piece" do
          context "as ajax post(xhr)" do
            before do
              xhr :post, :add_favorite, :fav_type => 'ArtPiece', :fav_id => @ap.id
            end
            it { expect(response).to be_success }
            it "adds favorite to user" do
              u = User.find(quentin.id)
              favs = u.favorites
              favs.map { |f| f.favoritable_id }.should include @ap.id
            end
            it { expect(response).to be_json }
          end
          context "as standard POST" do
            before do
              post :add_favorite, :fav_type => 'ArtPiece', :fav_id => @ap.id
            end
            it "returns success" do
              expect(response).to redirect_to @ap
            end
            it "sets flash with escaped name" do
              flash[:notice].should include HTMLEntities.new.encode(@ap.title, :named, :hexadecimal)
            end
            it "adds favorite to user" do
              u = User.find(quentin.id)
              favs = u.favorites
              favs.map { |f| f.favoritable_id }.should include @ap.id
            end
            context "then artist removes that artpiece" do
              before do
                @ap.destroy
              end
              it "art_piece is no longer in users favorite list" do
                u = User.find(quentin.id)
                u.favorites.should_not include @ap.id
              end
              it "art_piece owner should no longer have user in their favorite list" do
                a = Artist.find(@ap.artist_id)
                a.who_favorites_me.should_not include quentin
              end
            end
          end
        end
        context "add a favorite bogus model" do
          before do
            @nfavs = quentin.favorites.count
            post :add_favorite, :fav_type => 'Bogus', :fav_id => 2
          end
          it "returns 404" do
            expect(response).to be_missing
            response.code.should eql("404")
          end
        end
      end
    end
  end

  describe "#reset" do
    context "get" do
      render_views
      before do
        User.should_receive(:find_by_reset_code).and_return(fan)
        fan.update_attribute(:reset_code,'abc')
        get :reset, :reset_code => 'abc'
      end
      it { expect(response).to be_success }
      it "asks for password" do
        assert_select('#user_password')
      end
      it "asks for password confirmation" do
        assert_select('#user_password_confirmation')
      end
    end
    context "post" do
      render_views
      context "with passwords that don't match" do
        before do
          User.should_receive(:find_by_reset_code).with('abc').and_return(fan)
          post :reset, { :user => { :password => 'whatever',
              :password_confirmation => 'whatev' } ,
              :reset_code => 'abc' }
        end
        it { expect(response).to be_success }
        it "asks for password" do
          assert_select('#user_password')
        end
        it "asks for password confirmation" do
          assert_select('#user_password_confirmation')
        end
        it "has an error message" do
          assigns(:user).errors.full_messages.length.should eql 1
        end
      end
      context "with matching passwords" do
        before do
          User.should_receive(:find_by_reset_code).with('abc').and_return(fan)
          MAUFan.any_instance.should_receive(:delete_reset_code).exactly(:once)
          post :reset, { :user => { :password => 'whatever',
              :password_confirmation => 'whatever' },
              :reset_code => 'abc' }
        end
        it "returns redirect" do
          expect(response).to redirect_to "/login"
        end
        it "sets notice" do
          flash[:notice].should include('reset successfully for ')
        end
      end
    end
  end

  describe "resend_activation" do
    render_views
    before do
      get :resend_activation
    end

    it { expect(response).to be_success }

    it "shows email form" do
      assert_select('#user_email')
    end

    context "post with email that's not in the system" do
      before do
        User.should_receive(:find_by_email).and_return(nil)
        post :resend_activation, { :user => { :email => 'a@b.c' } }
      end
      it "redirect to root" do
        expect(response).to redirect_to( root_url )
      end
      it "has notice message" do
        flash[:notice].should include "sent your activation code to a@b.c"
      end
    end
    context "post with email that is for a fan" do
      before do
        post :resend_activation, { :user => { :email => 'a@b.c' } }
      end
      it "redirect to root" do
        expect(response).to redirect_to( root_url )
      end
      it "has notice message" do
        flash[:notice].should include "We sent your activation"
      end
    end
    context "post with email that is for an artist" do
      before do
        post :resend_activation, { :user => { :email => 'a@b.c' } }
      end
      it "redirect to root" do
        expect(response).to redirect_to( root_url )
      end
      it "has notice message" do
        flash[:notice].should include "sent your activation code to a@b.c"
      end
    end
  end

  describe "#forgot" do
    before do
      get :forgot
    end

    it { expect(response).to be_success }

    context "post a fan email" do
      it "looks up user by email" do
        User.should_receive(:find_by_email).with(fan.email).exactly(:once)
        post :forgot, :user => { :email => fan.email }
      end
      it "calls create_reset_code" do
        MAUFan.any_instance.should_receive(:create_reset_code).exactly(:once)
        post :forgot, :user => { :email => fan.email }
      end
      it "redirects to login" do
        post :forgot, :user => { :email => fan.email }
        expect(response).to redirect_to(login_url)
      end
    end
  end

  describe 'activate' do
    describe 'with valid activation code' do
      before do
        User.any_instance.should_receive(:activate!)
      end
      it 'redirects to login' do
        get :activate, :activation_code => pending_fan.activation_code
        expect(response).to redirect_to login_url
      end
      it 'flashes a notice' do
        get :activate, :activation_code => pending_fan.activation_code
        flash[:notice].should include 'Signup complete!'
      end
      it 'activates the user' do
        get :activate, :activation_code => pending_fan.activation_code
      end
    end
    describe 'with invalid activation code' do
      it 'redirects to login' do
        get :activate, :activation_code => 'blah'
        expect(response).to redirect_to login_url
      end
      it 'flashes an error' do
        get :activate, :activation_code => 'blah'
        /find an artist with that activation code/.match(flash[:error]).should_not be []
      end
      it 'does not blow away all activation codes' do
        FactoryGirl.create_list(:artist, 2)
        get :activate, :activation_code => 'blah'
        User.all.map{|u| u.activation_code}.select{|u| u.present?}.count.should > 0
      end
      it 'does not send email' do
        ArtistMailer.should_receive(:activation).never
        UserMailer.should_receive(:activation).never
        get :activate, :activation_code => 'blah'
      end
    end
  end

  describe "resend_activation" do
    before do
      get :resend_activation
    end

    it { expect(response).to be_success }
  end

  describe 'POST#notify' do
    let(:scam_msg) {
      "Morning,I would love to purchase Bait and tackle," +
      "please get back to me with details..I appreciate your prompt response"
    }
    let(:user) { joe }
    let(:user_id) { user.id }
    let(:comment) { 'whatever, yo' }
    let(:email) { 'mrrogers@example.com' }
    let(:name) { 'who dere' }
    let(:page) { users_path(user) }
    let(:honey) { nil }
    let(:notify_data) {
      { :id => user_id,
        :comment => comment,
        :email => email,
        :name => name,
        :page => page
      }
    }
    let(:notify_with_honey) {
      notify_data.merge(:i_love_honey => 'yum')
    }

    before do
      login_as quentin
    end
    context 'with valid data' do
      it 'emails the desired user and returns success' do
        ArtistMailer.should_receive(:notify).and_return( double(:deliver! => true) )
        post :notify,  notify_data
        expect(response).to be_success
      end
    end
    context 'if the honey pot is set' do
      it 'emails the admin users' do
        ArtistMailer.should_receive(:notify).never
        AdminMailer.should_receive(:spammer).and_return(double(:deliver! => true))
        post :notify, notify_with_honey
        expect(response).to be_success
      end
    end
    context 'if the body looks like spam' do
      let(:comment) { scam_msg }
      it 'emails the admin users' do
        ArtistMailer.should_receive(:notify).never
        AdminMailer.should_receive(:spammer).and_return(double(:deliver! => true))
        post :notify, notify_data
        expect(response).to be_success
      end
    end
    context 'if the email is in our hardcoded scammer list' do
      let(:email) { 'evott@rocketmail.com' }
      it 'emails the admin users' do
        ArtistMailer.should_receive(:notify).never
        AdminMailer.should_receive(:spammer).and_return(double(:deliver! => true))
        post :notify, notify_data
        expect(response).to be_success
      end
    end
    context 'if the email is in our scammer table' do
      let(:email) { scammer.email }
      it 'emails the admin users' do
        ArtistMailer.should_receive(:notify).never
        AdminMailer.should_receive(:spammer).and_return(double(:deliver! => true))
        post :notify, notify_data
        expect(response).to be_success
      end
    end
  end

  describe 'upload_profile' do
    describe 'unauthorized' do
      before do
        post :upload_profile
      end
      it_should_behave_like 'login required'
    end

    context "while authorized" do
      before do
        login_as fan
      end
      context "post " do
        let(:upload) { nil }
        let(:commit) { nil }
        let(:post_params) { { :upload => upload, :commit => commit } }
        context 'with no upload' do
          before do
            post :upload_profile, post_params
          end
          it 'redirects to the add profile page' do
            expect(response).to redirect_to add_profile_users_path
          end
          it 'sets a flash message without image' do
            expect(flash[:error]).to be_present
          end
        end
        context 'with a cancel' do
          let(:upload) { {'datafile' => double('UploadedFile', :original_filename => 'studio.png') } }
          let(:commit) { "Cancel" }
          before do
            post :upload_profile, post_params
          end
          it 'redirects to studio page' do
            expect(response).to redirect_to user_path(fan)
          end
        end

        context 'when image upload raises an error' do
          let(:upload) { {'datafile' => double('UploadedFile', :original_filename => 'studio.png') } }
          before do
            ArtistProfileImage.any_instance.should_receive(:save).and_raise MauImage::ImageError.new('eat it')
            post :upload_profile, post_params
          end
          it 'renders the form again' do
            expect(response).to redirect_to add_profile_users_path
          end
          it 'sets the error' do
            expect(flash[:error]).to be_present
          end
        end

        context 'with successful save' do
          let(:upload) { {'datafile' => double('UploadedFile', :original_filename => 'user.png') } }
          before do
            mock_user_image = double('MockUserImage', :save => true)
            ArtistProfileImage.should_receive(:new).and_return(mock_user_image)
          end
          it 'redirects to show page on success' do
            post :upload_profile, post_params
            expect(response).to redirect_to user_path(fan)
          end
          it 'sets a flash message on success' do
            post :upload_profile, post_params
            flash[:notice].should eql 'Your profile image has been updated.'
          end
        end
      end
    end
  end

  describe '#delete' do
    context 'non-admin' do
      before do
        delete :destroy, :id => jesse.id
      end
      it_should_behave_like 'not authorized'
    end
    context 'as yourself' do
      before do
        login_as admin
        delete :destroy, :id => admin.id
      end
      it 'redirects to users index' do
        expect(response).to redirect_to users_path
      end
      it 'flashes a message saying you can\'t delete yourself' do
        flash[:error].should eql "You can't delete yourself."
      end
    end
    context 'as admin' do
      before do
        login_as admin
      end
      context 'deleting a user' do
        it 'deactivates the user' do
          delete :destroy, :id => jesse.id
          jesse.reload
          jesse.state.should eql 'deleted'
        end
        it 'redirects to the users index page' do
          delete :destroy, :id => jesse.id
          expect(response).to redirect_to users_path
        end
      end
    end
  end

end
