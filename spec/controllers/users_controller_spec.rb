require 'rails_helper'

describe UsersController do
  let(:fan) { FactoryBot.create(:fan) }
  let(:quentin) { FactoryBot.create :artist }
  let(:admin) { FactoryBot.create :user, :admin, :active }
  let(:jesse) { quentin }
  let(:joe) { FactoryBot.create :artist, :active }
  let(:artist) { FactoryBot.create :artist, :active }
  let(:pending) { FactoryBot.create :artist, :pending }
  let(:pending_fan) { FactoryBot.create :fan, :pending }
  let(:art_pieces) do
    FactoryBot.create_list :art_piece, 4, :with_tag, artist:
  end
  let(:art_piece) do
    art_pieces.first
  end

  let(:scammer) { FactoryBot.create :scammer }

  def params_with_secret(opts)
    {
      secret_word: Conf.signup_secret_word,
    }.merge(opts)
  end

  before do
    allow(MailChimpService).to receive(:new).and_return(double.as_null_object)
  end

  describe '#index' do
    it 'redirects to artists index page' do
      get :index
      expect(response).to redirect_to artists_path
    end
  end

  describe '#new' do
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

  describe '#whoami' do
    context 'when not logged in' do
      it 'returns nil' do
        get :whoami
        expect(JSON.parse(response.body)).to eql({})
      end
    end
    context 'when logged in' do
      it 'returns login name' do
        login_as fan
        get :whoami
        expect(JSON.parse(response.body)['current_user']).to eql(
          'id' => fan.id,
          'login' => fan.login,
          'slug' => fan.slug,
        )
      end
    end
  end

  describe '#create' do
    context 'with denylisted domain' do
      before do
        # disable sweep of flash.now messages
        # so we can test them
        FactoryBot.create(:denylist_domain, domain: 'denylist.com')
        # allow(@controller).to receive(:sweep)
        allow(@controller).to receive(:verify_recaptcha).and_return(true)
        expect(@controller).to receive(:verify_secret_word).and_return(true)
      end
      it 'forbids email whose domain is on the denylist' do
        expect do
          post :create,
               params: params_with_secret(
                 mau_fan: {
                   login: 'newuser',
                   lastname: 'bmatic2',
                   firstname: 'bmatic2',
                   password: '8characters',
                   password_confirmation: '8characters',
                   email: 'bmatic2@denylist.com',
                 },
                 type: 'MauFan',
               )
        end.to change(User, :count).by(0)
      end
      it 'allows non denylist domain to add a user' do
        expect do
          post :create,
               params: params_with_secret(
                 mau_fan: {
                   login: 'newuser',
                   lastname: 'bmatic2',
                   firstname: 'bmatic2',
                   password: '8characters',
                   password_confirmation: '8characters',
                   email: 'bmatic2@nondenylist.com',
                 },
                 type: 'MauFan',
               )
        end.to change(User, :count).by(1)
      end
    end

    context 'with partial params' do
      context "login = 'newuser'" do
        before do
          post :create, params: { user: { login: 'newuser' }, type: 'MauFan' }
        end

        it 'login=>newuser : should return success' do
          expect(response).to be_successful
        end
      end
    end

    context 'valid user params and type = MauFan' do
      before do
        expect(UserMailer).to receive(:activation).exactly(:once).and_return(double('UserMailer::Activation', deliver_later: true))
        post :create,
             params: params_with_secret(
               mau_fan: {
                 login: 'newuser',
                 lastname: 'bmatic2',
                 firstname: 'bmatic2',
                 password: '8characters',
                 password_confirmation: '8characters',
                 email: 'bmatic2@b.com',
               },
               type: 'MauFan',
             )
      end
      it 'redirects to index' do
        expect(response).to redirect_to(login_url)
      end
      it 'sets flash indicating that activation email has been sent' do
        expect(flash[:notice]).to include(' ready to roll')
      end
      context 'creates an account' do
        before do
          @found_user = User.find_by(login: 'newuser')
        end
        it 'in the user database' do
          expect(@found_user).to be
        end
        it "whose state is 'active'" do
          expect(@found_user.state).to eq('active')
        end
        it "whose type is 'MauFan'" do
          @found_user.type == 'MauFan'
        end
      end
      it 'should register as a fan account' do
        expect(MauFan.find_by(login: 'newuser')).to be
      end
      it 'should not register as an artist account' do
        expect(Artist.find_by(login: 'newuser')).to be_nil
      end
      it 'should register as user account' do
        expect(User.find_by(login: 'newuser')).to be
      end
    end

    context 'valid user param (email/password only) and type = MauFan' do
      before do
        post :create,
             params: params_with_secret(
               mau_fan: {
                 password: '8characters',
                 password_confirmation: '8characters',
                 email: 'bmati2@b.com',
               },
               type: 'MauFan',
             )
      end
      it 'redirects to index' do
        expect(response).to redirect_to(login_url)
      end
      it 'sets flash indicating that activation email has been sent' do
        expect(flash[:notice]).to include(' ready to roll')
      end
      context 'creates an account' do
        before do
          @found_user = User.find_by(login: 'bmati2@b.com')
        end
        it 'in the user database' do
          expect(@found_user).to be
        end
        it "whose state is 'active'" do
          expect(@found_user.state).to eq('active')
        end
        it "whose type is 'MauFan'" do
          @found_user.type == 'MauFan'
        end
      end
      it 'should register as a fan account' do
        expect(MauFan.find_by(login: 'bmati2@b.com')).to be
      end
      it 'should not register as an artist account' do
        expect(Artist.find_by(login: 'bmati2@b.com')).to be_nil
      end
      it 'should register as user account' do
        expect(User.find_by(login: 'bmati2@b.com')).to be
      end
    end

    context 'valid artist params and type = Artist' do
      before do
        allow_any_instance_of(Artist).to receive(:activation_code).and_return('random_activation_code')
        expect_any_instance_of(Artist).to receive(:make_activation_code).at_least(1)
        post :create,
             params: params_with_secret(
               artist: {
                 login: 'newuser2',
                 lastname: 'bmatic',
                 firstname: 'bmatic',
                 password: '8characters',
                 password_confirmation: '8characters',
                 email: 'bmatic2@b.com',
               },
               type: 'Artist',
             )
      end
      it 'redirects to index' do
        expect(response).to redirect_to(login_url)
      end
      it 'sets flash indicating that activation email has been sent' do
        expect(flash[:notice]).to include('sign in to get started')
      end
      it 'creates an active account' do
        @found_artist = User.find_by(login: 'newuser2')
        expect(@found_artist).to be_present
        expect(@found_artist.state).to eql 'active'
        expect(@found_artist.type).to eql 'Artist'
        expect(@found_artist.artist_info).not_to be_nil
      end
      it 'should not register as a fan account' do
        expect(MauFan.find_by(login: 'newuser2')).to be_nil
      end
    end
  end

  describe '#show' do
    context 'looking for an invalid user id' do
      before do
        get :show, params: { id: 'eat it' }
      end
      it 'flashes an error' do
        expect(flash.now[:error]).to include 'not found'
      end
    end
    context 'looking for an artist' do
      before do
        get :show, params: { id: artist.id }
      end
      it { expect(response).to redirect_to artist_path(artist) }
    end
    context 'getting a users page while not logged in' do
      before do
        get :show, params: { id: fan.id }
      end
      it { expect(response).to be_successful }
    end
    context 'while logged in as an user' do
      before do
        login_as(fan)
        @logged_in_user = fan
        get :show, params: { id: fan.id }
      end
      it { expect(response).to be_successful }
    end
  end
  describe '#edit' do
    context 'while not logged in' do
      before do
        get :edit, params: { id: 123_123 }
      end
      it_behaves_like 'redirects to login'
    end
    context 'while logged in as an artist' do
      before do
        login_as(artist)
        get :edit, params: { id: 123_123 }
      end
      it 'GET should redirect to artist edit' do
        expect(response).to be_redirect
      end
      it 'renders the edit template' do
        expect(response).to redirect_to edit_artist_url(artist)
      end
    end
    context 'while logged in as an user' do
      before do
        login_as(fan)
        get :edit, params: { id: fan.id }
      end

      it { expect(response).to be_successful }
      it 'renders the user edit template' do
        expect(response).to render_template('edit')
      end
    end
  end

  describe 'login_required' do
    context 'get redirects to requested page via login' do
      before do
        get :edit, params: { id: 'nobody' }
      end
      it 'edit requires login' do
        expect(response).to redirect_to(new_user_session_path)
      end
      it 'auth system should try to record referrer' do
        expect(request.session[:return_to]).to eql edit_user_path(id: 'nobody')
      end
    end
  end
  describe '#update' do
    context 'while not logged in' do
      context 'with invalid params' do
        before do
          put :update, params: { id: quentin.id, user: {} }
        end
        it_behaves_like 'redirects to login'
      end
      context 'with valid params' do
        before do
          put :update, params: { id: quentin.id, user: { firstname: 'blow' } }
        end
        it_behaves_like 'redirects to login'
      end
    end
    context 'while logged in' do
      before do
        login_as(quentin, record: true)
        @logged_in_user = quentin
      end
      context 'with valid and a cancel' do
        before do
          put :update, params: { id: quentin.id, user: { firstname: 'blow' }, commit: 'Cancel' }
        end
        it { expect(response).to redirect_to(user_path(quentin)) }
      end
      context 'with valid params' do
        before do
          put :update, params: { id: quentin.id, user: { firstname: 'blow' } }
        end
        it 'redirects to user edit page' do
          expect(response).to redirect_to(edit_user_path(quentin))
        end
        it 'contains flash notice of success' do
          expect(flash[:notice]).to eql 'Your profile has been updated'
        end
        it 'updates user attributes' do
          expect(User.find(quentin.id).firstname).to eql 'blow'
        end
      end
      context 'with unicode name' do
        before do
          put :update, params: { id: quentin.id, user: { lastname: '蕭秋芬' } }
        end
        it 'redirects to user edit page' do
          expect(response).to redirect_to(edit_user_path(quentin))
        end
        it 'contains flash notice of success' do
          expect(flash[:notice]).to eql 'Your profile has been updated'
        end
        it 'updates user attributes' do
          expect(quentin.reload.lastname).to eql '蕭秋芬'
        end
      end
    end
  end

  describe '#reset' do
    let(:reset_code) { 'whatever' }
    context 'get' do
      before do
        expect(User).to receive(:find_by).with(reset_code:).and_return(fan)
        fan.update(reset_code:)
        get :reset, params: { reset_code: }
      end
      it { expect(response).to be_successful }
    end
    context 'get with invalid reset code' do
      before do
        get :reset, params: { reset_code: }
      end
      it { expect(response).to be_not_found }
    end
    context 'post' do
      context "with passwords that don't match" do
        before do
          expect(User).to receive(:find_by).with(reset_code:).and_return(fan)
          post :reset,
               params: {
                 user: {
                   password: 'whatever',
                   password_confirmation: 'whateveryo',
                 },
                 reset_code:,
               }
        end
        it { expect(response).to be_successful }
        it 'has an error message' do
          expect(assigns(:user).errors.full_messages.length).to eql 1
        end
      end
      context 'with matching passwords' do
        before do
          expect(User).to receive(:find_by).with(reset_code:).and_return(fan)
          allow(User).to receive(:find_by).and_call_original
          expect_any_instance_of(MauFan).to receive(:delete_reset_code).exactly(:once)
          post :reset,
               params: {
                 user: {
                   password: 'whatever',
                   password_confirmation: 'whatever',
                 },
                 reset_code:,
               }
        end
        it 'returns redirect' do
          expect(response).to redirect_to '/login'
        end
        it 'sets notice' do
          expect(flash[:notice]).to include('reset successfully for ')
        end
      end
    end
  end

  describe 'resend_activation' do
    let(:email) { 'a@b.c' }
    before do
      get :resend_activation
    end

    it { expect(response).to be_successful }

    context "post with email that's not in the system" do
      before do
        expect(User).to receive(:find_by).with(email:).and_return(nil)
        post :resend_activation, params: { user: { email: } }
      end
      it 'redirect to root' do
        expect(response).to redirect_to(root_url)
      end
      it 'has notice message' do
        expect(flash[:notice]).to include "sent your activation code to #{email}"
      end
    end
    context 'post with email that is for a fan' do
      before do
        post :resend_activation, params: { user: { email: } }
      end
      it 'redirect to root' do
        expect(response).to redirect_to(root_url)
      end
      it 'has notice message' do
        expect(flash[:notice]).to include 'We sent your activation'
      end
    end
    context 'post with email that is for an artist' do
      before do
        post :resend_activation, params: { user: { email: } }
      end
      it 'redirect to root' do
        expect(response).to redirect_to(root_url)
      end
      it 'has notice message' do
        expect(flash[:notice]).to include "sent your activation code to #{email}"
      end
    end
  end

  describe '#forgot' do
    before do
      get :forgot
    end

    it { expect(response).to be_successful }

    context 'post a fan email' do
      let(:make_forgot_request) do
        post :forgot, params: { user: { email: fan.email } }
      end
      it 'looks up user by email' do
        expect(User).to receive(:find_by).with(email: fan.email).exactly(:once)
        make_forgot_request
      end
      it 'calls create_reset_code' do
        expect_any_instance_of(MauFan).to receive(:create_reset_code).exactly(:once)
        make_forgot_request
      end
      it 'redirects to login' do
        make_forgot_request
        expect(response).to redirect_to(login_url)
      end
    end
  end

  describe 'activate' do
    describe 'with valid activation code' do
      let(:make_activate_call) do
        get :activate, params: { activation_code: pending_fan.activation_code }
      end
      before do
        expect_any_instance_of(MauFan).to receive(:activate!)
      end
      it 'redirects to login' do
        make_activate_call
        expect(response).to redirect_to login_url
      end
      it 'flashes a notice' do
        make_activate_call
        expect(flash[:notice]).to include 'to get started'
      end
      it 'activates the user' do
        make_activate_call
      end
    end
    describe 'with invalid activation code' do
      let(:make_activate_call) do
        get :activate, params: { activation_code: 'blah' }
      end
      it 'redirects to login' do
        make_activate_call
        expect(response).to redirect_to login_url
      end
      it 'flashes an error' do
        make_activate_call
        expect(flash[:error].include?('find an artist with that activation code')).not_to be []
      end
      it 'does not blow away all activation codes' do
        FactoryBot.create_list(:artist, 2)
        make_activate_call
        expect(User.all.map(&:activation_code).count(&:present?)).to be > 0
      end
      it 'does not send email' do
        expect(ArtistMailer).to receive(:activation).never
        expect(UserMailer).to receive(:activation).never
        make_activate_call
      end
    end
  end

  describe 'resend_activation' do
    before do
      get :resend_activation
    end

    it { expect(response).to be_successful }
  end

  describe '#delete' do
    context 'non-admin' do
      before do
        delete :destroy, params: { id: jesse.id }
      end
      it_behaves_like 'not authorized'
    end
    context 'as yourself' do
      before do
        login_as admin
        delete :destroy, params: { id: admin.id }
      end
      it 'redirects to users index' do
        expect(response).to redirect_to users_path
      end
      it 'flashes a message saying you can\'t delete yourself' do
        expect(flash[:error]).to eql "You can't delete yourself."
      end
    end
    context 'as admin' do
      before do
        login_as admin
      end
      context 'deleting a user' do
        it 'deactivates the user' do
          delete :destroy, params: { id: jesse.id }
          jesse.reload
          expect(jesse.state).to eql 'deleted'
        end
        it 'redirects to the users index page' do
          delete :destroy, params: { id: jesse.id }
          expect(response).to redirect_to users_path
        end
      end
    end
  end
end
