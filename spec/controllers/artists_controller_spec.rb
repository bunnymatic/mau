require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

include AuthenticatedTestHelper

describe ArtistsController do

  fixtures :users
  fixtures :artist_infos
  fixtures :art_pieces
  fixtures :studios
  fixtures :roles
  fixtures :media

  before do
    Rails.cache.stubs(:read).returns(nil)
  end

  describe "#index" do
    describe 'html' do
      integrate_views
      before do 
        get :index
      end
      it_should_behave_like 'one column layout'
      it "returns success" do
        response.should be_success
      end
      it "assigns artists" do
        assigns(:artists).length.should have_at_least(2).artists
      end
      it "set the title" do 
        assigns(:page_title).should == 'Mission Artists United - MAU Artists'
      end
      it "artists are all active" do
        assigns(:artists).each do |a|
          a.state.should == 'active'
        end
      end
      it "thumbs have representative art pieces in them" do
        ct = 0
        with_art, without_art = assigns(:artists).partition{|a| !a.representative_piece.nil?}
        assert(without_art.length >=1, 'Fixtures should include at least one activated artist without art')
        assert(with_art.length >=1, 'Fixtures should include at least one activated artist with art')
        assigns(:artists).each do |a|
          response.should have_tag(".allthumbs .thumb .name", /#{a.name}/);
        end
        with_art.each do |a|
          rep = a.representative_piece
          response.should have_tag(".allthumbs .thumb[pid=#{rep.id}] img[src*=#{a.representative_piece.filename}]")
        end
        without_art.each do |a|
          response.should have_tag(".allthumbs .thumb .name", /#{a.name}/);
        end
      end
      describe 'format=json' do
        before do
          get :index, :format => 'json', :suggest => 1, :input => 'jes'
        end
        it "returns success" do
          response.should be_success
        end
        it 'returns a hash with a list of artists' do
          j = JSON.parse(response.body)
          j.should be_a_kind_of Array
          (j.first.has_key? 'info').should be
          (j.first.has_key? 'value').should be
        end
        it 'list of artists matches the input parameter (in this case "jes")' do
          j = JSON.parse(response.body)
          j.should be_a_kind_of Array
          j.should have(1).artist_name
          j.first['value'].should == 'jesse ponce'
        end
      end
    end
  end
  describe 'roster view' do
    integrate_views
    before do
      get :index, :v => 'l'
    end
    it_should_behave_like 'one column layout'
    it "returns success" do
      response.should be_success
    end
    it "assigns artists" do
      assigns(:artists).length.should have_at_least(2).artists
    end
    it "set the title" do 
      assigns(:page_title).should == 'Mission Artists United - MAU Artists'
    end
    it "artists are all active" do
      assigns(:artists).each do |a|
        a.state.should == 'active'
      end
    end
  end
  describe "#update" do
    integrate_views
    before(:each) do
      @a = users(:artist1)
      @a.artist_info.open_studios_participation = '';
      @a.save
      @a.reload
    end
    context "while not logged in" do
      it_should_behave_like "get/post update redirects to login"
    end
    context "while logged in" do
      before do
        @new_bio = "this is the new bio"
        @old_bio = @a.artist_info.bio
        login_as(@a)

        @logged_in_user = @a
      end
      context "submit" do
        before do
          post :update, { :commit => 'submit', :artist => { :artist_info => {:bio => @newbio }}}
        end
        context "post with new bio data" do
          it "redirects to to edit page" do
            flash[:notice].should eql 'Update successful'
            response.should redirect_to(edit_artist_path(@a))
          end
          it "shows new bio in edit form" do
            get :edit
            response.should have_tag('textarea#artist_artist_info_bio')
          end
        end
      end
      context "cancel post with new bio data" do
        before do
          post :update, { :commit => 'cancel', :artist => { :artist_info => {:bio => @newbio }}}
        end
        it "redirects to user page" do
          response.should redirect_to(user_path(@a))
        end
        it "should have no flash notice" do
          flash[:notice].should be_nil
        end
        it "shouldn't change anything" do
          get :show, :id => @a.id
          response.should have_tag("div.bio-container")
          response.should include_text(@old_bio)
        end
      end
      context "update address" do
        before(:each) do 
          put :update, { :commit => 'submit', :artist => {:artist_info => {:street => '100 main st'}}}
        end
        it "contains flash notice of success" do
          flash[:notice].should eql "Update successful"
        end
        it "updates user address" do
          User.find(@logged_in_user.id).artist_info.address.should include '100 main st'
        end
      end
      context "update os status" do
        it "updates artists os status to true for 201104" do
          put :update, { :commit => 'submit', :artist => {:artist_info => {:os_participation => { '201104' => true }}}}
          User.find(@logged_in_user.id).os_participation['201104'].should be_true
        end
        it "updates artists os status to true for 201104 given '201104' => 'on'" do
          put :update, { :commit => 'submit', :artist => {:artist_info => {:os_participation => { '201104' => 'on' }}}}
          User.find(@logged_in_user.id).os_participation['201104'].should be_true
        end
        it "updates artists os status to false for 201104" do
          @logged_in_user.os_participation = {'201104' => 'true'}
          @logged_in_user.save
          put :update, { :commit => 'submit', :artist => {:artist_info => {:os_participation => { '201104' => 'false' }}}}
          User.find(@logged_in_user.id).os_participation['201104'].should be_nil
        end
        it "sets false if artist has no address" do
          ai = @logged_in_user.artist_info
          ai.lat = nil
          ai.lng = nil
          ai.street = ''
          ai.city = ''
          ai.addr_state = ''
          ai.zip = ''
          ai.open_studios_participation = ''
          ai.save
          @logged_in_user.studio_id = 0
          @logged_in_user.save
          @logged_in_user.reload
          put :update, { :commit => 'submit', :artist => {:artist_info => {:os_participation => { '201104' => false }}}}
          User.find(@logged_in_user.id).os_participation['201104'].should be_nil
        end
      end
    end
  end

  describe "#edit" do
    before(:each) do
      @a = users(:artist1)
    end
    context "while not logged in" do
      before(:each) do 
        get :edit
      end
      it_should_behave_like "redirects to login"
    end
    context "while logged in" do
      integrate_views
      before(:each) do
        login_as(@a)
        @logged_in_user = @a
        @logged_in_artist = @a
      end
      context "#edit" do
        before do
          get :edit
        end
        it_should_behave_like "logged in user"
        it_should_behave_like "logged in artist"
        it_should_behave_like "logged in edit page"

        it "returns success" do
          response.should be_success
        end
        it "has the edit form" do
          response.should have_tag("div#artist_edit");
        end
        it "has the artists email in the email form input field" do
          response.should have_tag("#info .inner-sxn input#artist_email[value=#{@a.email}]")
        end
        it "has the website input box with the artists website in it" do
          response.should have_tag("input#artist_url[value=#{@a.url}]")
        end
        it "has the artists correct links in their respective fields" do
          [:facebook, :blog].each do |k| 
            linkval = @a.send(k)
            linkid = "artist_artist_info_#{k}"
            tag = "input##{linkid}[value=#{linkval}]"
            response.should have_tag(tag)
          end
        end
        it "has the artists' bio textarea field" do
          get :edit
          response.should have_tag("textarea#artist_artist_info_bio", @a.artist_info.bio)
        end
        it "has heart notification checkbox checked" do
          response.should have_tag 'input#emailsettings_favorites[checked=checked]'
        end
        it 'has a hidden form for donation under the open studios section' do
          response.should have_tag '#paypal_donate_openstudios'
        end
      end
      context " if email_attrs['favorites'] is false " do
        before do
          esettings = @a.emailsettings
          esettings['favorites'] = false
          @a.emailsettings = esettings
          @a.save!
          @a.reload
          login_as(@a)
          get :edit
        end
        it "has heart notification checkbox unchecked" do 
          response.should have_tag "input#emailsettings_favorites" 
          response.should_not have_tag "input#emailsettings_favorites[checked=checked]" 
        end
      end
    end
  end
    
  describe "show" do
    integrate_views

    context "while not logged in" do
      before(:each) do 
        get :show, :id => users(:artist1).id
      end
      it "returns a page" do
        response.should be_success
      end
      it "has a twitter share icon it" do
        response.should have_tag '.micro-icon.twitter'
      end
      it "has a facebook share icon on it" do
        response.should have_tag('.micro-icon.facebook')
      end
      it "has a 'favorite' icon on it" do
        response.should have_tag('.micro-icon.heart')
      end
      it 'has thumbnails' do
        response.should have_tag("#bigthumbcolumn")
      end
      it 'has other thumbnails' do
        response.should have_tag('.artist-pieces')
      end
    end

    it "reports cannot find artist" do
      get :show, :id => users(:maufan1).id
      response.should have_tag('.rcol .error-msg')
      response.body.should match(/artist you were looking for was not found/)
    end

    context "while logged in" do
      before do
        @a = users(:artist1)
        login_as(@a)
        @logged_in_user = @a
        get :show, :id => @a.id
      end
      it_should_behave_like "logged in user"
      context "looking at your own page" do
        it "website is present" do
          response.should have_tag("div#u_website a[href=#{@a.url}]")
        end
        it "facebook is present and correct" do
          response.should have_tag("div#u_facebook a[href=#{@a.artist_info.facebook}]")
        end
        it "has sidebar nav when i look at my page" do
          get :show, :id => @a.id
          response.should have_tag('#sidebar_nav')
        end
        it "should not have heart icon" do
          response.should_not have_tag(".action-icons .micro-icon.heart")
          response.should have_tag("#sidebar_nav .micro-icon.heart")
        end
        it "should not have note icon" do
          response.should_not have_tag(".micro-icon.email")
        end
      end
      context "looking at someone elses page" do
        before(:each) do 
          get :show, :id => users(:joeblogs).id
        end
        it_should_behave_like "logged in user"
        it "should have heart icon" do
          response.should have_tag(".micro-icon.heart")
        end
        it "should have note icon" do
          response.should have_tag(".micro-icon.email")
        end
      end
      context "after a user favorites the logged in artist and show the artists page" do
        before do
          @u = users(:quentin)
          @u.add_favorite(@a)
          login_as(@a)
          get :show, :id => @a.id
        end
        it "returns success" do
          response.should be_success
        end
        it "has the user in the 'who favorites me' section" do
          response.should have_tag('#favorites_me div.thumb')
        end
        it "has a link to that users page" do
          response.should have_tag("#favorites_me a[href^=/users/#{@u.id}]")
        end
      end
    end

    context "after an artist favorites another artist and show the artists page" do
      before do
        a = users(:joeblogs)
        users(:artist1).add_favorite(a)
        login_as(users(:artist1))
        get :show, :id => users(:artist1).id
      end
      it "returns success" do
        response.should be_success
      end
      it "shows favorites on show page with links" do
        response.should have_tag("#my_favorites label a[href=#{favorites_user_path(users(:artist1))}]");
      end
    end

    context "while not logged in" do
      before(:each) do 
        @a = users(:artist1)
        get :show, :id => @a.id
      end
      it_should_behave_like "not logged in"
      it "website is present" do
        response.should have_tag("div#u_website a[href=#{@a.url}]")
      end
      it "has no sidebar nav " do
        response.should_not have_tag('#sidebar_nav')
      end
      it "facebook is present and correct" do
        response.should have_tag("div#u_facebook a[href=#{@a.artist_info.facebook}]")
      end
    end
  end

  describe "arrange art for an artist " do
    before(:each) do 
      # stash an artist and art pieces
      apids =[]
      a = users(:artist1)
      ap = art_pieces(:artpiece1)
      apids << ap.id
      ap = art_pieces(:artpiece2)
      apids << ap.id
      ap = art_pieces(:artpiece3)
      apids << ap.id
      @artist = a
      @artpieces = apids
    end
    it "most recently uploaded piece is the representative" do
      a = Artist.find_by_id(@artist.id)
      a.artist_info.representative_piece.title.should == "third"
    end

    it "returns art_pieces in created time order" do
      aps = @artist.art_pieces
      aps.count.should == 3
      aps[0].title.should == "third"
      aps[1].title.should == "art piece 2"
      aps[2].title.should == "first"
    end
    context "while logged" do
      before(:each) do
        login_as(@artist)
      end
      it "returns art_pieces in new order (2,1,3)" do
        order1 = [ @artpieces[1], @artpieces[0], @artpieces[2] ]

        # user should be logged in now
        post :setarrangement, { :neworder => order1.join(",") }
        response.should redirect_to user_url(@artist)
        a = Artist.find(@artist.id)
        aps = a.art_pieces
        aps.count.should == 3
        aps[0].title.should == "art piece 2"
        aps[1].title.should == "first"
        aps[2].title.should == "third"
        aps[0].artist.representative_piece.id.should==aps[0].id
      end

      it "returns art_pieces in new order (1,3,2)" do
        order1 = [ @artpieces[0], @artpieces[2], @artpieces[1] ]
        
        post :setarrangement, { :neworder => order1.join(",") }
        response.should redirect_to user_url(@artist)
        
        a = Artist.find(@artist.id)
        aps = a.art_pieces
        aps.count.should == 3
        aps[0].title.should == "first"
        aps[1].title.should == "third"
        aps[2].title.should == "art piece 2"
        aps[0].artist.representative_piece.id.should==aps[0].id
      end
    end
  end
  describe "- logged out" do
    context "post to set arrangement" do
      before do
        post :setarrangement, { :neworder => "1,2" }
      end
      it_should_behave_like "redirects to login"
    end
  end

  describe "#map" do
    integrate_views
    describe 'all artists' do
      before do
        get :map
      end
      it_should_behave_like 'one column layout'
      it "returns success" do
        response.should be_success
      end
      it "assigns map" do
        assigns(:map).should be
      end
      it "assigns roster" do
        assigns(:roster).should have_at_least(1).locations
      end
      it "artists should all be active" do
        assigns(:roster).values.flatten.each do |a|
          a.state.should == 'active'
        end
      end
      it "roster does not include artists outside of 'the mission'" do
        ne = [ 37.76978184422388, -122.40539789199829 ]
        sw = [ 37.747787573475506, -122.42919445037842 ]
        roster = assigns(:roster).values.flatten.each do |a|
          lat,lng = a.address_hash[:latlng]
          
          (sw[0] < lat && lat < ne[0]).should be_true, "Latitude #{lat} is not within bounds"
          (sw[1] < lng && lng < ne[1]).should be_true ,"Longitude #{lng} is not within bounds"
        end
      end
      it "get's map info all artists" do
        ArtistsController.any_instance.expects(:get_map_info).times(assigns(:roster).values.flatten.count)
        get :map
      end
    end
    describe 'os only' do
      before do
        get :map, :osonly => true
      end
      it "returns success" do
        response.should be_success
      end
      it "assigns map" do
        assigns(:map).should be
      end
      it "assigns roster" do
        assigns(:roster).should have_at_least(1).locations
      end
      it "artists should all be active" do
        assigns(:roster).values.flatten.each do |a|
          a.state.should == 'active'
        end
      end

      it "roster does not include artists outside of 'the mission'" do
        ne = [ 37.76978184422388, -122.40539789199829 ]
        sw = [ 37.747787573475506, -122.42919445037842 ]
        roster = assigns(:roster).values.flatten.each do |a|
          lat,lng = a.address_hash[:latlng]
          
          (sw[0] < lat && lat < ne[0]).should be_true, "Latitude #{lat} is not within bounds"
          (sw[1] < lng && lng < ne[1]).should be_true ,"Longitude #{lng} is not within bounds"
        end
      end
    end
  end

  describe "#admin_index" do
    context "while not logged in" do
      before do
        get :admin_index
      end
      it "redirects to login" do
        response.should redirect_to '/error'
      end
    end
    context "while logged in as user" do
      before do
        a = users(:artist1)
        login_as(a)
        get :admin_index
      end
      it "should report error" do
        response.should redirect_to '/error'
      end
    end
    context "logged in as admin" do
      integrate_views
      before do
        ArtistInfo.any_instance.stubs(:os_participation => {'201204' => true})
        Artist.any_instance.stubs(:os_participation => {'201204' => true})

        login_as(:admin)
        get :admin_index
      end
      it "returns success" do
        response.should be_success
      end
      it "renders sort by links" do
        response.should have_tag('.sortby a', :count => 14)
      end
      it 'renders a csv export link' do
        response.should have_tag('a.export-csv button', /export/)
      end
      it 'renders an update os status button' do
        response.should have_tag('button.update-artists', /update os status/)
      end
      it 'renders controls for hiding rows' do
        response.should have_tag('.hide-rows .row-info');
      end
      it 'renders .pending rows for all pending artists' do
        response.should have_tag('tr.pending', :count => Artist.all.select{|s| s.state == 'pending'}.count)
      end
      it 'renders created_at date for all pending artists' do
        Artist.all.select{|s| s.state == 'pending'}.each do |a|
          response.should have_tag('tr.pending td', /#{a.created_at.strftime('%m/%d/%y')}/)
        end
      end
      it 'renders .participating rows for all pending artists' do
        response.should have_tag('tr.participating', :count => Artist.all.select{|a| a.os_participation['201204']}.count)
      end
      it 'renders activation link for inactive artists' do
        response.should have_tag('.activation_link', :count => Artist.all.select{|s| s.state == 'pending'}.count)
        response.should have_tag('.activation_link', /http:\/\/#{Conf.site_url}\/activate\/#{users(:pending_artist).activation_code}/)
      end
      it 'renders forgot link if there is a reset code' do
        response.should have_tag('.forgot_password_link', :count => Artist.all.select{|s| s.reset_code.present?}.count)
        response.should have_tag('.forgot_password_link', /http:\/\/#{Conf.site_url}\/reset\/#{users(:reset_password).reset_code}/)
      end
    end
  end

     
  describe "- named routes" do
    describe 'collection paths' do
      [:destroyart, :arrangeart, :thumbs, :setarrangement, :deleteart].each do |path|
        it "should have #{path} as artists collection path" do
          eval('%s_artists_path.should == \'/artists/%s\'' % [path,path])
        end
      end
    end      
    describe 'member paths' do
      [:bio].each do |path|
        it "should have #{path} as an artist member path" do
          @a = Artist.first
          eval("%s_artist_path(@a).should == '/artists/%s/%s'" % [ path, @a.id, path ])
        end
      end
    end
  end


  describe "- route generation" do
    it "should map controller artists, id 10 and action show to /artists/10" do
      route_for(:controller => "artists", :id => "10", :action => "show").should == "/artists/10"
    end
    it "should map edit action properly" do
      route_for(:controller => "artists", :action => "edit").should == "/artists/edit"
    end
    
    it "should map users/index to artists" do
      route_for(:controller => "artists", :action => "index").should == "/artists"
    end
  end

  describe "- route recognition" do
    context "/artists/edit" do
      it "map get to artists controller edit method" do
        params_from(:get, "/artists/edit").should == {:controller => "artists", :action => "edit" }
      end
    end
    context "/artists/10" do
      it "map PUT to update" do 
        params_from(:put, "/artists/10").should == {:controller => "artists", :action => "update", :id => "10" }
      end
      it "map GET to show" do
        params_from(:get, "/artists/10").should == {:controller => "artists", :action => "show", :id => "10" }
      end
      it "map POST to action == 10 (nonsense)" do
        params_from(:post, "/artists/10").should == {:controller => "artists", :action => "10" }
      end
      it "map DELETE /artists/10 as destroy" do
        params_from(:delete, "/artists/10").should == {:controller => "artists", :action => "destroy", :id => "10" }
      end
    end
  end
end
