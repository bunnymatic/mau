require 'spec_helper'

include AuthenticatedTestHelper

describe StudiosController do

  fixtures :users, :studios, :artist_infos, :art_pieces, :roles_users, :roles

  let(:studio_list) { controller.send(:get_studio_list) }
  let(:fan) { users(:maufan1) }
  let(:manager) { users(:manager) }
  let(:manager_studio) { manager.studio }

  context 'as an admin' do
    before do
      login_as :admin
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
          put :create, :studio => studio_attrs
        }.to change(Studio, :count).by(1)
      end
      it 'renders new on failure' do
        expect{
          put :create, :studio => {:name =>''}
          expect(response).to render_template 'new'
        }.to change(Studio, :count).by(0)

      end
    end

    describe '#update' do
      it 'updates a studio' do
        post :update, :id => studios(:as).id, :studio => {:name =>'new name'}
        expect(studios(:as).reload.name).to eql 'new name'
      end
      it 'renders edit on failure' do
        post :update, :id => studios(:as).id, :studio => {:name =>''}
        expect(response).to render_template 'edit'
      end
    end
  end

  describe 'safe_find' do
    it 'does not raise when you ask for an unknown studio' do
      expect{ controller.send(:safe_find,'bogus') }.to_not raise_error
    end
    it 'finds the studio if it exists' do
      expect(controller.send(:safe_find,studios(:as).id)).to eql studios(:as)
    end
  end

  describe 'get_studio_list' do
    it 'includes all studios with at least MIN_STUDIOS_PER_ARTIST artists' do
      counts = studio_list.map{|s| s.artists.active.count}
      expect(counts.min).to be > StudiosController::MIN_ARTISTS_PER_STUDIO
    end
    it 'includes all studios with artists' do
      expect(studio_list.select{|s| s.name == 'Independent Studios'}.length).to eql 1
    end
  end

  describe "#index" do
    context "while not logged in" do
      render_views
      context 'default mode' do
        before do
          get :index
        end
        it_should_behave_like "not logged in"
        it "last studio should be independent studios" do
          assigns(:studios).studios.last.name.should eql 'Independent Studios'
        end

        it "sets view_mode to name" do
          assigns(:view_mode).should eql 'name'
        end
      end
      context "with view mode set to count" do
        before do
          get :index, :v => 'c'
        end
        it "sets view_mode to count" do
          assigns(:view_mode).should eql 'count'
        end
      end
    end
    context "while logged in as an art fan" do
      render_views
      before do
        login_as fan
        @logged_in_user = fan
        get :index
      end
      it_should_behave_like "logged in user"
    end
    describe 'json' do
      before do
        get :index, :format => 'json'
      end
      it_should_behave_like 'successful json'
      it 'returns all studios' do
        j = JSON.parse(response.body)
        j.count.should eql studio_list.count
      end
    end
  end


  describe "#show keyed studios" do

    render_views

    Hash[Studio.all.map{|s| [s.name.parameterize('_').to_s, s.name]}].each do |k,v|
      it "should return studio #{v} for key #{k}" do
        get :show, :id => k
        assert_select('h4', :text => v)
      end
    end
  end

  describe "#show" do
    render_views

    describe 'unknown studio' do
      before do
        get :show, "id" => 'blurp'
      end
      it {expect(response).to redirect_to studios_path}
      it 'sets the flash' do
        flash[:error].should be_present
      end
    end

    describe 'indy studio' do
      before do
        get :show, "id" => 0
      end
      it "sets the studio to the indy studio" do
        assigns(:studio).studio.should eql Studio.indy
      end
    end

    describe 'individual studio' do
      describe 'html' do
        before do
          Studio.any_instance.stub(:phone => '1234569999')
          Studio.any_instance.stub(:cross_street => 'fillmore')
          get :show, "id" => studios(:as).id
        end
        it "last studio should be independent studios" do
          assigns(:studios).last.name.should eql 'Independent Studios'
        end
        it "studios are in alpha order by our fancy sorter (ignoring the) with independent studios at the end" do
          s = assigns(:studios)
          s.pop
          def prep_name(a)
            a.name.downcase.gsub(/^the\ /, '')
          end

          s.sort_by{|a| prep_name(a)}.map(&:name).should eql s.map(&:name)
        end
        it "studio url is a link" do
          assert_select("div.url a[href=#{studios(:as).url}]")
        end
        it "studio includes cross street if there is one" do
          assert_select('.address', /\s+fillmore/)
        end
        it "studio info includes a phone if there is one" do
          assert_select('.phone', :text => '(123) 456-9999')
        end
      end

      describe 'json' do
        before do
          get :show, :id => studios(:as).id, :format => 'json'
        end
        it_should_behave_like 'successful json'
        it 'returns the studio data' do
          j = JSON.parse(response.body)
          j['studio']['name'].should eql studios(:as).name
          j['studio']['street'].should eql studios(:as).street
        end
        it 'includes a list of artist ids' do
          j = JSON.parse(response.body)
          j['studio']['artists'].should be_a_kind_of Array
        end
      end
    end
  end

  describe 'destroy' do
    describe 'unauthorized' do
      before do
        delete :destroy, :id => Studio.all[2].id
      end
      it_should_behave_like 'not authorized'
    end
    [:editor, :manager].each do |u|
      describe "as #{u}" do
        before do
          login_as u
          delete :destroy, :id => Studio.all[2].id
        end
        it_should_behave_like 'not authorized'
      end
    end
    describe 'as admin' do
      before do
        login_as(:admin)
      end
      it 'deletes the studio' do
        expect { delete :destroy, :id => Studio.all[2] }.to change(Studio, :count).by(-1)
      end
      it 'sets artists\' to indy for all artists in the deleted studio' do
        s = Studio.all[2]
        artist_ids = s.artists.map(&:id)
        assert(artist_ids.length > 0, 'You need to have a couple artists on that studio in your fixtures')
        delete :destroy, :id => s.id
        users = User.find(artist_ids)
        users.all?{|a| a.studio_id == 0}.should be_true, 'Not all the artists were moved into the "Indy" studio'
      end
    end
  end


  # studio manager required endpoints
  [:add_profile, :edit, :unaffiliate_artist].each do |endpoint|
    describe "#{endpoint}" do
      describe 'unauthorized' do
        before do
          get endpoint, :id => Studio.all[2].id
        end
        it_should_behave_like 'not authorized'
      end
      describe 'as editor' do
        before do
          login_as :editor
          get endpoint, :id => studios(:as)
        end
        it_should_behave_like 'not authorized'
      end
      describe 'as manager' do
        before do
          login_as :manager
        end
        context 'not my studio' do
          before do
            get endpoint, :id => studios(:as)
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

  describe '#add_profile' do
    let(:manager) { users(:manager) }
    before do
      login_as manager
      get :add_profile, :id => manager.studio.id
    end
    it { expect(response).to be_success }
    it { assigns(:studio).should eql manager.studio }
  end

  describe 'edit' do
    render_views
    [:manager, :admin].each do |user_key|
      context "as #{user_key}" do
        let(:user) { users(user_key) }
        let(:studio) { users(:manager).studio }

        before do
          login_as user
          get :edit, :id => studio.id
        end
        it_should_behave_like 'returns success'
        it 'shows the studio info in a form' do
          assert_select 'form input#studio_url' do |tag|
            tag.first.attributes['value'].should eql studio.url
          end
          assert_select 'form input#studio_name' do |tag|
            tag.first.attributes['value'].should eql studio.name
          end
          assert_select 'form input[type=submit]' do |tag|
            tag.first.attributes['value'].should eql 'Update Studio'
          end
        end
        it 'shows the logo' do
          assert_select '.block.image img'
        end
        it 'has a link to update the logo' do
          assert_select ".block.image a[href=#{add_profile_studio_path(studio)}]"
        end
        it 'lists the active artists' do
          assert_select "li.artist", :count => studio.artists.active.count
        end
        it 'includes unaffiliate links for each artist thats not the current user' do
          ct = studio.artists.active.reject{|a| a == user}.length
          assert_select "li.artist a", :text => 'X', :count => ct
        end
      end
    end
  end

  describe 'upload_profile' do
    describe 'unauthorized' do
      before do
        post :upload_profile
      end
      it_should_behave_like 'not authorized'
    end
    describe 'as editor' do
      before do
        login_as :editor
        post :upload_profile
      end
      it_should_behave_like 'not authorized'
    end
    describe 'as manager' do
      context 'not my studio' do
        before do
          login_as :manager
          post :upload_profile, :id => studios(:as)
        end
        it 'redirects to the referer' do
          expect(response).to redirect_to SHARED_REFERER
        end
        it 'flashes an error' do
          flash[:error].should match /not a manager of that studio/
        end
      end
    end

    context "while authorized" do
      context "post " do
        let(:upload) { nil }
        let(:commit) { nil }
        let(:post_params) { { :id => manager_studio, :upload => upload, :commit => commit } }
        before do
          login_as manager
        end
        context 'with no upload' do
          before do
            post :upload_profile, post_params
          end
          it 'redirects to the add profile page' do
            expect(response).to redirect_to add_profile_studio_path(manager_studio)
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
            expect(response).to redirect_to studio_path(manager_studio)
          end
        end

        context 'when image upload raises an error' do
          let(:upload) { {'datafile' => double('UploadedFile', :original_filename => 'studio.png') } }
          before do
            StudioImage.any_instance.should_receive(:save).and_raise MauImage::ImageError.new('eat it')
            post :upload_profile, post_params
          end
          it 'renders the form again' do
            expect(response).to redirect_to add_profile_studio_path(manager_studio)
          end
          it 'sets the error' do
            expect(flash[:error]).to be_present
          end
        end

        context 'with successful save' do
          let(:upload) { {'datafile' => double('UploadedFile', :original_filename => 'studio.png') } }
          before do
            mock_studio_image = double('MockStudioImage', :save => true)
            StudioImage.should_receive(:new).and_return(mock_studio_image)
          end
          it 'redirects to show page on success' do
            post :upload_profile, post_params
            expect(response).to redirect_to studio_path(manager_studio)
          end
          it 'sets a flash message on success' do
            post :upload_profile, post_params
            flash[:notice].should eql 'Studio Image has been updated.'
          end
        end
      end
    end
  end

  describe 'unaffiliate_artist' do
    let(:manager_role) { Role.find_by_role('manager') }
    let(:admin) { users(:admin) }
    let(:artist) { (studio.active_artists.to_a - [admin]).first }
    let(:non_studio_artist) { studios(:s1890).active_artists.first }
    let(:studio) { studios(:as) }

    before do
      login_as admin
    end

    context 'artist to unaffiliate is not the logged in artist' do
      it 'removes the artist from the studio' do
        expect {
          post :unaffiliate_artist, :id => studio.id, :artist_id => artist.id
        }.to change(studio.active_artists, :count).by(-1)
      end
      it 'does not add any studios' do
        expect {
          post :unaffiliate_artist, :id => studio.id, :artist_id => artist.id
        }.to change(Studio, :count).by(0)
      end
      it 'does nothing if the artist is not in the studio' do
        expect {
          post :unaffiliate_artist, :id => studio.id, :artist_id => non_studio_artist.id
        }.to change(studio.active_artists, :count).by(0)
      end
      it 'redirects to the studio edit page' do
        post :unaffiliate_artist, :id => studio.id, :artist_id => artist.id
        expect(response).to redirect_to edit_studio_path(studios(:as))
      end
    end

    context 'artist to unaffiliate is the logged in artist' do
      let(:artist) { admin }
      before do
        # validate fixtures
        expect(admin.studio).to eql studio
      end

      it 'does not let you unaffiliate yourself' do
        post :unaffiliate_artist, :id => studio.id, :artist_id => artist.id
        expect(response).to redirect_to edit_studio_path(studios(:as))
        expect(artist.studio).to eql studio
      end
    end

  end

  describe 'admin_index' do
    render_views
    describe 'unauthorized' do
      before do
        get :admin_index
      end
      it_should_behave_like 'not authorized'
    end
    describe "as editor" do
      before do
        login_as :editor
        get :admin_index
      end
      it_should_behave_like 'not authorized'
    end
    [:manager, :admin].each do |u|
      describe "as #{u}" do
        before do
          login_as u
          get :admin_index
        end
        it_should_behave_like 'returns success'
        it 'shows a table of all studios' do
          Studio.all.each do |s|
            assert_select ".admin-table tr td a[href=#{studio_path(s)}]", s.name
            assert_select ".admin-table tr td a[href=#{s.url}]" if s.url && s.url.present?
          end
        end
      end
    end

    context 'as manager' do
      before do
        login_as :manager
        @my_studio = users(:manager).studio
        get :admin_index
      end
      it 'has no destroy links' do
        css_select(".admin-table tr td a").map(&:name).should_not include 'Destroy'
      end
      it 'shows an edit link for my studio only' do
        assert_select ".admin-table tr td a[href=#{edit_studio_path(@my_studio)}]"
      end
      it 'has no link to add a studio' do
        css_select(".admin-table a[href=#{new_studio_path}]").should be_empty
      end
    end
    context 'as admin' do
      before do
        login_as :admin
        get :admin_index
      end
      it 'shows an edit link for all studios' do
        assert_select(".admin-table tr td a") do |tag|
          txt = tag.map(&:to_s)
          txt.select{|t| /studios\/\d+\/edit/.match(t)}.count.should > 1
        end
      end
      it 'shows destroy links for all studios' do
        assert_select(".admin-table tr td a[data-method=delete]") do |tags|
          (tags.map(&:to_s)).all?{|t| /Destroy/ =~ t}.should be_true
        end
      end
      it 'includes a link to add a studio' do
        assert_select ".admin-table a[href=#{new_studio_path}]"
      end
    end
  end
end
