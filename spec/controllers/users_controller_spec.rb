require 'spec_helper'

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
        flash.now[:error].should include 'robot'
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
      it { expect(response).to be_success }
      it "has the users name on it" do
        assert_select '.artist__name', :text => fan.get_name
      end
      it "has a profile image" do
        assert_select ".artist__image"
      end
      it "shows the users website" do
        assert_select ".link a[href=#{fan.url}]"
      end
    end
    context "while logged in as an user" do
      before do
        login_as(fan)
        @logged_in_user = fan
        get :show, :id => fan.id
      end
      it { expect(response).to be_success }
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
      before do
        login_as(fan)
        get :edit, :id => fan.id
      end

      it { expect(response).to be_success }
      it "renders the user edit template" do
        expect(response).to render_template("edit")
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
        get :edit, id: 'nobody'
      end
      it "add_favorite requires login" do
        expect(response).to redirect_to( new_user_session_path )
      end
      it "auth system should try to record referrer" do
        request.session[:return_to].should eql edit_user_path(id: 'nobody')
      end
    end
  end
  describe "#update", eventmachine: true do
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
          expect(flash[:notice]).to eql "Your profile has been updated"
        end
        it "updates user attributes" do
          expect(User.find(quentin.id).firstname).to eql "blow"
        end
      end
    end
  end

  describe "POST favorites" do
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
            flash[:notice].should include html_encode(@ap.title)
          end
          it "adds favorite to user" do
            u = User.find(quentin.id)
            favs = u.favorites
            favs.map { |f| f.favoritable_id }.should include @ap.id
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
    context "get with invalid reset code" do
      before do
        get :reset, :reset_code => 'abc'
      end
      it { expect(response.code).to eql "404" }
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
