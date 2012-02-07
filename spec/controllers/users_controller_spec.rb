require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

include AuthenticatedTestHelper

describe UsersController do
  
  fixtures :users
  fixtures :art_pieces
  fixtures :favorites # even though fixture is empty - this forces a db clear between tests

  before do
    ####
    # stub mailchimp calls
    User.any_instance.stubs(:mailchimp_list_subscribe)
    Artist.any_instance.stubs(:mailchimp_list_subscribe)
    MAUFan.any_instance.stubs(:mailchimp_list_subscribe)
  end

  it "actions should fail if not logged in" do
    exceptions = [:index, :show, :artists, :resend_activation, :favorites,
                  :forgot, :unsuspend, :destroy, :create, :new, :activate, 
                  :notify, :noteform, :purge, :reset, :favorites_notify]
    controller_actions_should_fail_if_not_logged_in(:user, 
                                                    :except => exceptions)
  end
  describe "#new" do
    integrate_views

    before do
      # disable sweep of flash.now messages
      # so we can test them
      @controller.instance_eval{flash.stubs(:sweep)}
      get :new
    end
    it_should_behave_like 'one column layout'
    it "has fan signup form" do
      response.should have_tag("#fan_signup_form")
    end
    it "has artist signup form" do
      response.should have_tag("#artist_signup_form")
    end
    it "has 2 first name text boxes" do
      response.should have_tag("#artist_firstname")
      response.should have_tag("#mau_fan_firstname")
    end
    it "has lastname text box" do
      response.should have_tag("#mau_fan_lastname")
      response.should have_tag("#artist_lastname")
    end
  end

  describe "#create" do
    it "return 404 with :artist = {}" do
      post :create,  :artist => {}
      response.should be_missing
    end
    it "return 404 with :user = {}" do
      post :create, :user => {} 
      response.should be_missing
    end
    it "return 404 with params :mau_fan {}" do
      post :create, :mau_fan => {}
      response.should be_missing
    end
    it "should be 404 with no input params" do
      post :create
      response.should be_missing
    end
    
    context "with partial params" do
      before do
        # disable sweep of flash.now messages
        # so we can test them
        @controller.instance_eval{flash.stubs(:sweep)}
      end
      context "login = 'newuser'" do
        before do
          post :create, :user => { :login => 'newuser' }, :type => "MAUFan" 
        end
        
        it "login=>newuser : should return success" do 
          response.should be_success
        end
        
        it "sets a flash.now indicating failure" do
          post :create, :user => { :login => 'newuser' }, :type => "MAUFan" 
        end
      end
    end
    context "valid user params and type = MAUFan" do
      before do
        MAUFan.any_instance.expects(:make_activation_code).at_least(1)
        MAUFan.any_instance.expects(:subscribe_and_welcome)
        UserMailer.expects(:deliver_activation).once
        post :create, :mau_fan => { :login => 'newuser',
          :password_confirmation => "blurpit", 
          :lastname => "bmatic2", 
          :firstname => "bmatic2", 
          :password => "blurpit", 
          :email => "bmatic2@b.com" }, :type => "MAUFan" 
      end
      it "redirects to index" do
        response.should redirect_to( login_url )
      end
      it "sets flash indicating that activation email has been sent" do
        flash[:notice].should include_text(" ready to roll")
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
        MAUFan.any_instance.expects(:subscribe_and_welcome)
        post :create, :mau_fan => { 
          :password_confirmation => "blurpit", 
          :password => "blurpit", 
          :email => "bmati2@b.com" }, :type => "MAUFan" 
      end
      it "redirects to index" do
        response.should redirect_to( login_url )
      end
      it "sets flash indicating that activation email has been sent" do
        flash[:notice].should include_text(" ready to roll")
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
        Artist.any_instance.expects(:make_activation_code).at_least(1)
        MAUFan.any_instance.expects(:subscribe_and_welcome).never
        post :create, :artist => { :login => 'newuser2',
          :password_confirmation => "blurpt", 
          :lastname => "bmatic", 
          :firstname => "bmatic", 
          :password => "blurpt", 
          :email => "bmatic2@b.com" }, :type => "Artist" 
      end
      it "redirects to index" do
        response.should redirect_to( root_url )
      end
      it "sets flash indicating that activation email has been sent" do
        flash[:notice].should include_text(" email with your activation code")
      end
      context "creates an account" do
        before do
          @found_artist = User.find_by_login("newuser2")
        end
        it "in the artist database" do
          @found_artist.should be
        end
        it "whose state is 'pending'" do
          @found_artist.state.should be == 'pending'
        end
        it "whose type is 'Artist'" do
          @found_artist.type == 'Artist'
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
    integrate_views
    before do
      @a = users(:artist1)
      @u = users(:maufan1)
    end
    context "while not logged in" do
      before do 
        get :show
      end
      it_should_behave_like "not logged in"
    end
    context "getting a users page while not logged in" do
      before do
        get :show, :id => @u.id
      end
      it_should_behave_like 'two column layout'
      it "returns a valid page" do
        response.should be_success
      end
      it "has the users name on it" do
        response.should have_tag '#artist_profile_name h4', :text => "#{@u.firstname} #{@u.lastname}"
      end
      it "has a profile image" do
        response.should have_tag "img.profile"
      end
      it "shows the users website" do
        response.should have_tag "#u_website a[href=#{@u.url}]"
      end
    end
    context "while logged in as an user" do
      before(:each) do 
        login_as(@u)
        @logged_in_user = @u
        get :show, :id => @u.id
      end
      it_should_behave_like 'two column layout'
      it_should_behave_like "logged in user"
      it "has sidebar nav when i look at my page" do
        response.should have_tag('#sidebar_nav')
      end
      it "has no sidebar nav when i look at someone elses page" do
        get :show, :id => users(:artfan).id
        response.should_not have_tag('#sidebar_nav')
      end
    end
  end
  describe "#edit" do
    before(:each) do
      @a = users(:artist1)
      @a.save!
      @u = users(:maufan1)
      @u.save!
    end
    context "while not logged in" do
      integrate_views
      before(:each) do 
        get :edit
      end
      it_should_behave_like "redirects to login"
    end
    context "while logged in as an artist" do
      before(:each) do
        login_as(@a)
        get :edit
      end
      it "GET should redirect to artist edit" do
        response.should be_redirect
      end
      it "renderers the edit template" do
        response.should redirect_to edit_artist_url(@a)
      end
    end
    context "while logged in as an user" do
      integrate_views
      before(:each) do
        login_as(@u)
        get :edit
      end

      it_should_behave_like 'one column layout'
      it_should_behave_like "logged in edit page"

      it "returns success" do
        response.should be_success
      end
      it "renders the user edit template" do
        response.should render_template("edit")
      end
      it "has no heart notification checkbox" do
        response.should_not have_tag "#notification input#emailsettings_favorites"
      end
    end
  end

  describe "login_required" do
    context " post redirects to root (referrer)" do
      before(:each) do 
        @u = users(:quentin)
        post :add_favorite
      end
      it "add_favorite requires login" do
        response.should redirect_to( new_session_path )
      end
      it "auth system should try to record referrer" do
        request.session[:return_to].should eql SHARED_REFERER
      end
    end
    context "get redirects to requested page via login" do
      before(:each) do 
        @u = users(:quentin)
        get :edit
      end
      it "add_favorite requires login" do
        response.should redirect_to( new_session_path )
      end
      it "auth system should try to record referrer" do
        request.session[:return_to].should eql "/users/edit"
      end
    end
  end
  describe "update" do
    before(:each) do 
      @u = users(:quentin)
    end
    context "while not logged in" do
      it_should_behave_like "get/post update redirects to login"
      context "with invalid params" do
        before(:each) do
          put :update, :id => @u.id, :user => {}
        end
        it_should_behave_like "redirects to login"
      end
      context "with valid params" do
        before(:each) do
          put :update, :id => @u.id, :user => { :firstname => 'blow' }
        end
        it_should_behave_like "redirects to login"
      end
    end
    context "while logged in" do
      before(:each) do 
        login_as(@u)
        @logged_in_user = @u
      end
      context "with empty params" do
        before(:each) do
          put :update, :id => @u.id, :user => {}
        end
        it "redirects to user edit page" do
          response.should redirect_to(edit_user_path(@u))
        end
        it "contains flash notice of success" do
          flash[:notice].should eql "Update successful"
        end
      end
      context "with valid params" do
        before(:each) do 
          put :update, :id => @u.id, :user => {:firstname => 'blow'}
        end
        it "redirects to user edit page" do
          response.should redirect_to(edit_user_path(@u))
        end
        it "contains flash notice of success" do
          flash[:notice].should eql "Update successful"
        end
        it "updates user attributes" do
          User.find(@u.id).firstname.should eql "blow"
        end
      end
    end
  end

  describe "favorites" do
    integrate_views
    context "show" do
      context "while not logged in" do
        before do
          get :favorites, :id => users(:maufan1).id
        end
        it_should_behave_like 'one column layout'
        it "returns sucess" do
          response.should be_success
        end
        it "doesn't have the no favorites msg" do
          response.should_not have_tag('.no-favorites-msg')
        end
      end
      context "while logged in as fan with no favorites" do
        before do
          ArtPiece.any_instance.stubs(:artist).returns(Artist.new(:login => 'blow'))
          @u = users(:maufan1)
          login_as(@u)
          get :favorites, :id => @u.id
        end
        it_should_behave_like 'one column layout'
        it "returns success" do
          response.should be_success
        end
        it "gets some random links assigned" do
          assigns(:random_picks).size.should > 2
        end
        it "has the no favorites msg" do
          response.should have_tag('.no-favorites-msg', :count => 1)
        end
        it "has section for 'artist by name'" do
          response.should have_tag('h5', :text => 'Find Artists by Name')
        end
        it "has section for 'artist by medium'" do
          response.should have_tag('h5', :text => 'Find Artists by Medium')
        end
        it "has section for 'artist by tag'" do
          response.should have_tag('h5', :text => 'Find Artists by Tag')
        end
        it "does not show the favorites sections" do
          response.should_not have_tag('.favorites > h5', :include_text => 'Artists')
          response.should_not have_tag('.favorites > h5', :include_text => 'Art Pieces')
        end
        it "doesn't show a button back to the artists page" do
          response.should_not have_tag('.buttons form')
        end
      end
      context "while logged in as artist " do
        before do
          ArtPiece.any_instance.stubs(:artist).returns(Artist.new(:login => 'blurp'))
          @a = users(:artist1)
          login_as(@a)
        end
        it "returns success" do
          get :favorites, :id => @a.id
          response.should be_success
        end
        context "who has favorites" do
          before do
            User.any_instance.stubs(:get_profile_path).returns("/this")
            ArtPiece.any_instance.stubs(:get_path).with('small').returns("/this")
            ap = art_pieces(:hot)
            ap.artist_id = users(:joeblogs)
            ap.save!
            aa = users(:joeblogs)
            @a.add_favorite ap
            @a.add_favorite aa
            assert @a.favorites.count >= 1
            assert @a.fav_artists.count >= 1
            assert @a.fav_art_pieces.count >= 1
            get :favorites, :id => @a.id
          end
          it_should_behave_like 'one column layout'
          it "returns success" do
            response.should be_success
          end
          it "does not assign random picks" do
            assigns(:random_picks).should be_nil
          end
          it "shows the title" do
            response.should have_tag('h4', :include_text => 'My Favorites')
          end
          it "favorites sections show and include the count" do
            response.should have_tag('h5', :text => "Artists (#{@a.fav_artists.count})")
            response.should have_tag("h5", :text => "Art Pieces (#{@a.fav_art_pieces.count})")
          end
          it "shows the 1 art piece favorite" do
            response.should have_tag('.favorites .art_pieces .thumb', :count => 1, :include_text => 'by blupr')
          end
          it "shows the 1 artist favorite" do
            response.should have_tag('.favorites .artists .thumb', :count => 1)
          end
          it "shows a delete button for each favorite" do
            response.should have_tag('.favorites li .trash', :count => @a.favorites.count)
          end
          it "shows a button back to the artists page" do
            response.should have_tag('.buttons form')
          end
        end
      end
      context "logged in as user looking at artist who has favorites " do
        before do 
          User.any_instance.stubs(:get_profile_path).returns("/this")
          ArtPiece.any_instance.stubs(:get_path).with('small').returns("/this")
          a = users(:artist1)
          aa = users(:joeblogs)
          ap = art_pieces(:hot)
          ap.artist_id = aa.id
          ap.save!
          a.add_favorite ap
          a.add_favorite aa
          assert a.fav_artists.count >= 1
          assert a.fav_art_pieces.count >= 1
          login_as users(:maufan1)
          get :favorites, :id => a.id
          @a = a
        end
        it_should_behave_like 'one column layout'
        it "returns success" do
          response.should be_success
        end
        it "shows the title" do
          response.should have_tag('h4', :include_text => @a.get_name )
          response.should have_tag('h4', :include_text => 'Favorites')
        end
        it "shows the favorites sections" do
          response.should have_tag('h5', :include_text => 'Artists')
          response.should have_tag('h5', :include_text => 'Art Pieces')
        end
        it "shows the 1 art piece favorite" do
          response.should have_tag('.favorites .art_pieces .thumb', :count => 1)
        end
        it "shows the 1 artist favorite" do
          response.should have_tag('.favorites .artists .thumb', :count => 1)
        end
        it "does not show a delete button for each favorite" do
          response.should_not have_tag('.favorites li .trash')
        end
      end
    end 
    context "POST favorites" do
      context "requesting anything but a post" do
        it "redirects to login" do
          put :add_favorite
          response.should redirect_to(new_session_path)
          delete :add_favorite
          response.should redirect_to(new_session_path)
          get :add_favorite
          response.should redirect_to(new_session_path)
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
          @u = users(:quentin)
          login_as(@u)
          @a = users(:artist1)
          @ap = art_pieces(:namewithtag) 
          @ap.artist = @a
          @ap.save.should be_true      
        end
        context "add a favorite artist" do
          before do
            post :add_favorite, :fav_type => 'Artist', :fav_id => @a.id
          end
          it "returns success" do
            response.should redirect_to(artist_path(@a))
          end
          it "adds favorite to user" do
            u = User.find(@u.id)
            favs = u.favorites
            favs.map { |f| f.favoritable_id }.should include @a.id
          end
          context "then remove that artist from favorites" do
            before do 
              post :remove_favorite, :fav_type => "Artist", :fav_id => @a.id
            end
            it "redirects to the referer" do
              response.should redirect_to( SHARED_REFERER )
            end
            it "that artist is no longer a favorite" do
              u = User.find(@u.id)
              favs = u.favorites
              favs.map { |f| f.favoritable_id }.should_not include @a.id
            end
          end
        end
        context "add a favorite art_piece" do
          context "as ajax post(xhr)" do
            before do
              xhr :post, :add_favorite, :fav_type => 'ArtPiece', :fav_id => @ap.id
            end
            it "returns success" do
              response.should be_success
            end
            it "adds favorite to user" do
              u = User.find(@u.id)
              favs = u.favorites
              favs.map { |f| f.favoritable_id }.should include @ap.id
            end
            it "returns json data" do
              response_should_be_json
            end
          end
          context "as standard POST" do
            before do
              post :add_favorite, :fav_type => 'ArtPiece', :fav_id => @ap.id
            end
            it "returns success" do
              response.should redirect_to(art_piece_path(@ap))
            end
            it "sets flash with escaped name" do
              flash[:notice].should include '&#x3c;script&#x3e;'
            end
            it "adds favorite to user" do
              u = User.find(@u.id)
              favs = u.favorites
              favs.map { |f| f.favoritable_id }.should include @ap.id
            end
            context "then artist removes that artpiece" do
              before do
                @ap.destroy
              end
              it "art_piece is no longer in users favorite list" do
                u = User.find(@u.id)
                u.favorites.should_not include @ap.id
              end
              it "art_piece owner should no longer have user in their favorite list" do
                a = Artist.find(@ap.artist_id)
                a.who_favorites_me.should_not include @u
              end
            end
          end
        end
        context "add a favorite bogus model" do
          before do
            @nfavs = @u.favorites.count
            post :add_favorite, :fav_type => 'Bogus', :fav_id => 2 
          end
          it "returns 404" do
            response.should be_missing
            response.code.should eql("404")
          end
        end
      end
    end
  end

  describe "#reset" do
    context "get" do
      integrate_views
      before do
        User.expects(:find_by_reset_code).returns(users(:artfan))
        u = users(:artfan)
        u.reset_code = 'abc'
        u.save
        get :reset, :reset_code => 'abc'
      end
      it "returns success" do
        response.should be_success
      end
      it "asks for password" do
        response.should have_tag('#user_password')
      end
      it "asks for password confirmation" do
        response.should have_tag('#user_password_confirmation')
      end
    end
    context "post" do
      integrate_views
      context "with passwords that don't match" do
        before do
          User.expects(:find_by_reset_code).with('abc').returns(users(:artfan))
          post :reset, { :user => { :password => 'whatever', 
              :password_confirmation => 'whatev' } ,
              :reset_code => 'abc' }
        end
        it "returns success" do
          response.should be_success
        end
        it "asks for password" do
          response.should have_tag('#user_password')
        end
        it "asks for password confirmation" do
          response.should have_tag('#user_password_confirmation')
        end
        it "has an error message" do
          assigns(:user).errors.length.should == 1
        end
      end
      context "with matching passwords" do
        before do
          User.expects(:find_by_reset_code).with('abc').returns(users(:artfan))
          MAUFan.any_instance.expects(:delete_reset_code).once
          post :reset, { :user => { :password => 'whatever', 
              :password_confirmation => 'whatever' },
              :reset_code => 'abc' }
        end
        it "returns redirect" do
          response.should redirect_to "/"
        end
        it "sets notice" do
          flash[:notice].should include_text('reset successfully for ')
        end
      end
    end
  end

  describe "resend_activation" do
    integrate_views
    before do
      get :resend_activation
    end

    it "returns sucess" do
      response.should be_success
    end
    
    it "shows email form" do
      response.should have_tag('#user_email')
    end
    
    context "post with email that's not in the system" do
      before do 
        User.expects(:find_by_email).returns(nil)
        post :resend_activation, { :user => { :email => 'a@b.c' } }
      end
      it "redirect to root" do
        response.should redirect_to( root_url )
      end
      it "has error message" do
        flash[:error].length.should > 1
      end
    end
    context "post with email that is for a fan" do
      before do 
        User.expects(:find_by_email).returns(users(:artfan))
        post :resend_activation, { :user => { :email => 'a@b.c' } }
      end
      it "redirect to root" do
        response.should redirect_to( root_url )
      end
      it "has notice message" do
        flash[:notice].should include_text "MAU Fan accounts need no activation"
      end
    end
    context "post with email that is for an artist" do
      before do 
        User.expects(:find_by_email).returns(users(:quentin))
        post :resend_activation, { :user => { :email => 'a@b.c' } }
      end
      it "redirect to root" do
        response.should redirect_to( root_url )
      end
      it "has notice message" do
        flash[:notice].should include_text "sent your activation code to #{users(:quentin).email}"
      end
    end
  end

  describe "#forgot" do
    before do
      get :forgot
    end

    it "returns sucess" do
      response.should be_success
    end
    
    context "post a fan email" do
      it "looks up user by email" do
        User.expects(:find_by_email).with(users(:artfan).email).times(1)
        post :forgot, :user => { :email => users(:artfan).email }
      end
      it "calls create_reset_code" do
        MAUFan.any_instance.expects(:create_reset_code).times(1)
        post :forgot, :user => { :email => users(:artfan).email }
      end
      it "redirects to login" do
        post :forgot, :user => { :email => users(:artfan).email }
        response.should redirect_to(login_url)
      end
    end
  end

  describe 'activate' do
    describe 'with no activation code' do
      it 'redirects to login' do
        get :activate
        response.should redirect_to login_url
      end
    end
    describe 'with valid activation code' do
      it 'redirects to login' do
        get :activate, :activation_code => users(:pending).activation_code
        response.should redirect_to login_url
      end
      it 'flashes a notice' do
        get :activate, :activation_code => users(:pending).activation_code
        flash[:notice].should include 'Signup complete!'
      end
      it 'activates the user' do
        pending
        User.any_instance.expects('activate!')
        get :activate, :activation_code => users(:pending).activation_code
      end
      it 'sends an email to the user' do
        pending
        UserMailer.expects(:deliver_activation).once
        get :activate, :activation_code => users(:pending).activation_code
      end        
    end
    describe 'with invalid activation code' do
      it 'redirects to login' do
        get :activate, :activation_code => 'blah'
        response.should redirect_to login_url
      end
      it 'flashes an error' do
        get :activate, :activation_code => 'blah'
        /find an artist with that activation code/.match(flash[:error]).should_not be []
      end
      it 'does not blow away all activation codes' do
        get :activate, :activation_code => 'blah'
        User.all.map{|u| u.activation_code}.select{|u| u.present?}.count.should > 0
      end
      it 'does not send email' do
        ArtistMailer.expects(:deliver_activation).never
        UserMailer.expects(:deliver_activation).never
        get :activate, :activation_code => 'blah'
      end
    end
  end

  describe "resend_activation" do
    before do
      get :resend_activation
    end

    it "returns sucess" do
      response.should be_success
    end
  end

  describe "- routes" do
    it "route controller=users, action=edit to /users/edit" do
      route_for(:controller => "users", :action => "edit").should == '/users/edit'
    end
  end

  describe "- named routes" do
    it "addprofile as users collection path" do
      addprofile_users_path.should == '/users/addprofile'
    end
    it "upload_profile as users collection path" do
      upload_profile_users_path.should == '/users/upload_profile'
    end
  end
  describe "- route recognition" do
    it "should recognize get /users/10/edit as edit user id = 10" do
      params_from(:get, "/users/10/edit").should == {:controller => 'users', :action => 'edit', :id => '10' }
    end
    
    it "should recognize PUT /users/10 as update" do
      params_from(:put, "/users/10").should == {:controller => 'users', :action => 'update', :id => '10' }
    end
    it "should recognize GET /users/10 as show" do
      params_from(:get, "/users/10").should == {:controller => 'users', :action => 'show', :id => '10' }
    end
    it "should recognize POST /users/10 as nonsense (action 10)" do
      params_from(:post, "/users/10").should == {:controller => 'users', :action => '10' }
    end
    it "should recognize DELETE /users/10 as show" do
      params_from(:delete, "/users/10").should == {:controller => 'users', :action => 'destroy', :id => '10' }
    end
  end
end
