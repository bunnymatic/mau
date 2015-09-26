require 'spec_helper'
require 'htmlentities'

describe Admin::StudiosController do

  let!(:studio) { FactoryGirl.create(:studio, :with_artists) }
  let(:studio2) { FactoryGirl.create(:studio, :with_artists) }
  let(:manager) { FactoryGirl.create(:artist, :manager, :active, studio: studio) }
  let(:manager_studio) { manager.studio }
  let(:editor) { FactoryGirl.create(:artist, :editor, :active, studio: studio)}
  let(:admin) { FactoryGirl.create(:artist, :admin, :active, studio: studio) }

  context 'as an admin' do
    before do
      login_as(admin)
    end
    describe '#new' do
      before do
        get :new
      end
      it 'setups up a new studio' do
        expect(assigns(:studio)).to be_a_kind_of Studio
      end
    end

    describe '#create' do
      let(:studio_attrs) { FactoryGirl.attributes_for(:studio) }
      it 'setups up a new studio' do
        expect{
          put :create, studio: studio_attrs
        }.to change(Studio, :count).by(1)
      end
      it 'renders new on failure' do
        expect{
          put :create, studio: {name:''}
          expect(response).to render_template 'new'
        }.to change(Studio, :count).by(0)

      end
    end

    describe '#update' do
      it 'updates a studio' do
        post :update, id: studio.to_param, studio: {name:'new name'}
        expect(studio.reload.name).to eql 'new name'
      end
      it 'renders edit on failure' do
        post :update, id: studio.to_param, studio: {name:''}
        expect(response).to render_template 'edit'
      end
    end
  end


  describe 'destroy' do
    describe 'unauthorized' do
      before do
        delete :destroy, id: studio.to_param
      end
      it_should_behave_like 'not authorized'
    end
    [:editor, :manager].each do |u|
      describe "as #{u}" do
        before do
          #login_as self.send(u)
          delete :destroy, id: studio.to_param
        end
        it_should_behave_like 'not authorized'
      end
    end
    describe 'as admin' do
      before do
        login_as(admin)
      end
      it 'deletes the studio' do
        expect { delete :destroy, id: studio.to_param }.to change(Studio, :count).by(-1)
      end
      it 'sets artists\' to indy for all artists in the deleted studio' do
        artist_ids = studio.artists.map(&:id)
        assert(artist_ids.length > 0, 'You need to have a couple artists on that studio in your fixtures')
        delete :destroy, id: studio.to_param
        users = User.find(artist_ids)
        users.all?{|a| a.studio_id == 0}.should be_true, 'Not all the artists were moved into the "Indy" studio'
      end
    end
  end


  # studio manager required endpoints
  [:edit, :unaffiliate_artist].each do |endpoint|
    describe "#{endpoint}" do
      describe 'unauthorized' do
        before do
          get endpoint, id: studio
        end
        it_should_behave_like 'not authorized'
      end
      describe 'as editor' do
        before do
          login_as editor
          get endpoint, id: studio.to_param
        end
        it_should_behave_like 'not authorized'
      end
      describe 'as manager' do
        before do
          login_as manager
        end
        context 'not my studio' do
          before do
            get endpoint, id: studio2.id
          end
          it 'redirects to the referrer' do
            expect(response).to redirect_to SHARED_REFERER
          end
          it 'flashes an error' do
            flash[:error].should match /not a manager of that studio/
          end
        end
      end
    end
  end

  describe 'edit' do
    render_views
    context "as a manager" do
      before do
        login_as manager
        get :edit, id: manager.studio.to_param
      end
      it { expect(response).to be_success }
      it 'shows the studio info in a form' do
        assert_select 'form input#studio_url' do |tag|
          tag.first.attributes['value'].should eql studio.url
        end
        assert_select 'form input#studio_name' do |tag|
          tag.first.attributes['value'].should eql html_encode(manager.studio.name, :hexadecimal)
        end
        assert_select 'form input[type=submit]' do |tag|
          tag.first.attributes['value'].should eql 'Update Studio'
        end
      end
      it 'shows the logo' do
        assert_select '.block.image img'
      end
      it 'lists the active artists' do
        assert_select "li.artist", count: studio.artists.active.count
      end
      it 'includes unaffiliate links for each artist thats not the current user' do
        ct = studio.artists.active.reject{|a| a == manager}.length
        assert_select "li.artist a", text: 'X', count: ct
      end
    end
  end

  describe 'unaffiliate_artist' do
    let(:manager_role) { Role.find_by_role('manager') }
    let(:artist) { (studio.artists.active.to_a - [admin]).first }
    let(:non_studio_artist) { studio2.artists.active.first }

    before do
      login_as admin
    end

    context 'artist to unaffiliate is not the logged in artist' do
      it 'removes the artist from the studio' do
        expect {
          post :unaffiliate_artist, id: studio.to_param, artist_id: artist.id
        }.to change(studio.artists.active, :count).by(-1)
      end
      it 'does not add any studios' do
        expect {
          post :unaffiliate_artist, id: studio.to_param, artist_id: artist.id
        }.to change(Studio, :count).by(0)
      end
      it 'does nothing if the artist is not in the studio' do
        expect {
          post :unaffiliate_artist, id: studio.to_param, artist_id: non_studio_artist.id
        }.to change(studio.artists.active, :count).by(0)
      end
      it 'redirects to the studio edit page' do
        post :unaffiliate_artist, id: studio.to_param, artist_id: artist.id
        expect(response).to redirect_to edit_admin_studio_path(studio)
      end
    end

    context 'artist to unaffiliate is the logged in artist' do
      let(:artist) { admin }
      before do
        # validate fixtures
        expect(admin.studio).to eql studio
      end

      it 'does not let you unaffiliate yourself' do
        post :unaffiliate_artist, id: studio.to_param, artist_id: artist.id
        expect(response).to redirect_to edit_admin_studio_path(studio)
        expect(artist.studio).to eql studio
      end
    end

  end

  describe 'index' do
    render_views
    describe 'unauthorized' do
      before do
        get :index
      end
      it_should_behave_like 'not authorized'
    end
    describe "as editor" do
      before do
        login_as editor
        get :index
      end
      it_should_behave_like 'not authorized'
    end
    describe "as a manager" do
      before do
        login_as manager
        get :index
      end
      it { expect(response).to be_success }
      it 'shows a table of all studios' do
        Studio.all.each do |s|
          assert_select "table tr td a[href=#{studio_path(s)}]", html_encode(s.name, :hexadecimal)
          assert_select "table tr td a[href=#{s.url}]" if s.url && s.url.present?
        end
      end
    end

    context 'as manager' do
      before do
        login_as manager
        @my_studio = manager.studio
        get :index
      end
      it 'has no destroy links' do
        expect(css_select("table tr td a i.icon-remove")).to be_empty
      end
      it 'shows an edit link for my studio only' do
        assert_select "table tr td a[href=#{edit_admin_studio_path(@my_studio)}]"
        assert_select("table tr td a .fa-edit", count: 1)
      end
      it 'has no link to add a studio' do
        expect(css_select("table a[href=#{new_admin_studio_path}]")).to be_empty
      end
    end
    context 'as admin' do
      before do
        login_as(admin)
        get :index
      end
      it 'shows an edit and destroy links for all studios except indy' do
        expected_count = Studio.count
        assert_select("table tr td a .fa-edit", count: expected_count)
        assert_select("table tr td a[data-method=delete] .fa-remove", count: expected_count)
      end
      it 'includes a link to add a studio' do
        assert_select "a[href=#{new_admin_studio_path}]"
      end
    end
  end

end
