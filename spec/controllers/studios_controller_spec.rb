require 'spec_helper'

include AuthenticatedTestHelper

describe StudiosController do

  fixtures :users, :studios, :artist_infos, :art_pieces, :roles_users, :roles

  describe "#index" do
    context "while not logged in" do
      render_views
      before do
        get :index
      end
      it_should_behave_like "not logged in"
      it "last studio should be independent studios" do
        assigns(:studios).last.name.should eql 'Independent Studios'
      end
      it "studios are in alpha order by our fancy sorter (ignoring the) with independent studios at the end" do
        s = assigns(:studios)
        s.pop
        s.sort{|a,b| a.name.downcase.gsub(/^the\ /, '') <=> b.name.downcase.gsub(/^the\ /,'')}.map(&:name).should eql s.map(&:name)
      end
      it "sets view_mode to name" do
        assigns(:view_mode).should eql 'name'
      end

      context "with view mode set to count" do
        before do
          get :index, :v => 'c'
        end
        it "sets view_mode to count" do
          assigns(:view_mode).should eql 'count'
        end
        it "studios are sorted by count descending" do
          artist_count = assigns(:studios_by_count).map{|s| s.artists.active.count}
          min = artist_count.first
          artist_count.each do |ct|
            ct.should <= min
            min = ct
          end
        end
      end
    end
    context "while logged in as an art fan" do
      render_views
      before do
        u = users(:maufan1)
        login_as(users(:maufan1))
        @logged_in_user = u
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
        j.count.should eql Studio.all.count
      end
    end
  end


  describe "#show keyed studios" do

    render_views

    Hash[Studio.all.map{|s| [s.name.parameterize('_').to_s, s.name]}].each do |k,v|
      it "should return studio #{v} for key #{k}" do
        get :show, "id" => k
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
      it {response.should redirect_to studios_path}
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
          s.sort{|a,b| a.name.downcase.gsub(/^the\ /, '') <=> b.name.downcase.gsub(/^the\ /,'')}.map(&:name).should eql s.map(&:name)
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
  [:addprofile, :edit, :unaffiliate_artist].each do |endpoint|
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
            response.should redirect_to SHARED_REFERER
          end
          it 'flashes an error' do
            flash[:error].should match /not a manager of that studio/
          end
        end
      end
    end
  end

  describe '#addprofile' do
    let(:manager) { users(:manager) }
    before do
      login_as manager
      get :addprofile, :id => manager.studio.id
    end
    it { response.should be_success }
    it { assigns(:studio).should eql manager.studio }
  end

  describe 'edit' do
    render_views
    [:manager, :admin].each do |user|
      context "as #{user}" do
        before do
          login_as user
          @user = users(user)
          @my_studio = users(:manager).studio
          get :edit, :id => @my_studio.id
        end
        it_should_behave_like 'returns success'
        it 'shows the studio info in a form' do
          assert_select 'form input#studio_url' do |tag|
            tag.first.attributes['value'].should eql @my_studio.url
          end
          assert_select 'form input#studio_name' do |tag|
            tag.first.attributes['value'].should eql @my_studio.name
          end
          assert_select 'form input[type=submit]' do |tag|
            tag.first.attributes['value'].should eql 'Update Studio Info'
          end
        end
        it 'shows the logo' do
          assert_select '.block.image img'
        end
        it 'has a link to update the logo' do
          assert_select ".block.image a[href=#{addprofile_studio_path(@my_studio)}]"
        end
        it 'lists the active artists' do
          assert_select "li.artist", :count => @my_studio.artists.active.count
        end
        it 'includes unaffiliate links for each artist thats not the current user' do
          assert_select "li.artist a", :text => 'X', :count => (@my_studio.artists.active.reject{|a| a == @user}.count)
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
          response.should redirect_to SHARED_REFERER
        end
        it 'flashes an error' do
          flash[:error].should match /not a manager of that studio/
        end
      end
    end
  end

  describe 'unaffiliate_artist' do
    before do
      login_as :admin
      @artist = studios(:as).artists.active[1]
    end
    it 'removes the artist from the studio' do
      expect {
        post :unaffiliate_artist, :id => studios(:as).id, :artist_id => @artist.id
      }.to change(studios(:as).artists.active, :count).by(-1)
    end
    it 'does not add any studios' do
      expect {
        post :unaffiliate_artist, :id => studios(:as).id, :artist_id => @artist.id
      }.to change(Studio, :count).by(0)
    end
    it 'does nothing if the artist is not in the studio' do
      expect {
        post :unaffiliate_artist, :id => studios(:as).id, :artist_id => studios(:s1890).artists.first.id
      }.to change(studios(:as).artists.active, :count).by(0)
    end
    it 'redirects to the studio edit page' do
      post :unaffiliate_artist, :id => studios(:as).id, :artist_id => @artist.id
      response.should redirect_to edit_studio_path(studios(:as))
    end
    it 'removes the manager role if it\'s on the user but does not remove the role itself' do
      @artist.roles << Role.find_by_role('manager')
      @artist.save
      post :unaffiliate_artist, :id => studios(:as).id, :artist_id => @artist.id
      @artist.reload
      @artist.roles.should_not include Role.find_by_role('manager')
      Role.find_by_role('manager').should be
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
