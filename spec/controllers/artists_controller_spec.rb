require 'spec_helper'
require 'htmlentities'
include AuthenticatedTestHelper

describe ArtistsController do

  fixtures :users, :roles_users, :artist_infos, :art_pieces, :studios, :roles, :media, :art_piece_tags, :art_pieces_tags, :cms_documents

  before do
    Rails.cache.stub(:read => nil)
  end

  let(:artist1) { users(:artist1) }
  let(:artist1_info) { artist1.artist_info }

  describe "#index" do
   describe 'logged in as admin' do
      render_views
      before do
        login_as :admin
        get :index
      end
      it_should_behave_like 'returns success'
      it_should_behave_like 'logged in as admin'
    end


    describe 'html' do
      render_views
      before do
        get :index
      end
      it_should_behave_like 'one column layout'
      it { response.should be_success }
      it "assigns artists" do
        assigns(:artists).length.should have_at_least(2).artists
      end
      it "set the title" do
        assigns(:page_title).should eql 'Mission Artists United - MAU Artists'
      end
      it "artists are all active" do
        assigns(:artists).each do |a|
          a.state.should eql 'active'
        end
      end
      it 'shows no artists without a representative piece' do
        with_art, without_art = assigns(:artists).partition{|a| !a.representative_piece.nil?}
        without_art.length.should eql 0
      end
      it "thumbs have representative art pieces in them" do
        with_art, without_art = assigns(:artists).partition{|a| !a.representative_piece.nil?}
        assert(with_art.length >=1, 'Fixtures should include at least one activated artist with art')
        assigns(:artists).each do |a|
          assert_select(".allthumbs .thumb .name", /#{a.name}/);
        end
        with_art.each do |a|
          rep = a.representative_piece
          assert_select(".allthumbs .thumb[pid=#{rep.id}] img[src*=#{rep.filename}]")
        end
        without_art.each do |a|
          assert_select(".allthumbs .thumb .name", /#{a.name}/);
        end
      end
    end

    describe 'json' do
      before do
        get :index, :format => 'json'
      end
      it_should_behave_like 'successful json'
      it 'returns all active artists' do
        j = JSON.parse(response.body)
        j.count.should eql Artist.active.count
      end
    end
  end

  describe '#index roster view' do
    render_views
    before do
      get :index, :v => 'l'
    end
    it_should_behave_like 'one column layout'
    it { response.should be_success }
    it "assigns artists" do
      assigns(:artists).length.should have_at_least(2).artists
    end
    it "set the title" do
      assigns(:page_title).should eql 'Mission Artists United - MAU Artists'
    end
    it "artists are all active" do
      assigns(:artists).each do |a|
        a.state.should eql 'active'
      end
    end
  end
  describe "#update" do
    render_views
    before do
      artist1_info.update_attribute(:open_studios_participation,'')
    end
    context "while not logged in" do
      context "with invalid params" do
        before do
          put :update, :id => artist1.id, :user => {}
        end
        it_should_behave_like "redirects to login"
      end
      context "with valid params" do
        before do
          put :update, :id => artist1.id, :user => { :firstname => 'blow' }
        end
        it_should_behave_like "redirects to login"
      end
    end
    context "while logged in" do
      before do
        @new_bio = "this is the new bio"
        @old_bio = artist1_info.bio
        login_as(artist1)
        @logged_in_user = artist1
        ArtistInfo.any_instance.stub(:compute_geocode => [-22,123])
      end
      context "submit" do
        context "post with new bio data" do
          it "redirects to to edit page" do
            put :update, { :commit => 'submit', :artist => { :artist_info => {:bio => @newbio }}}
            flash[:notice].should eql 'Update successful'
            response.should redirect_to(edit_artist_path(artist1))
          end
          it 'publishes an update message' do
            Messager.any_instance.should_receive(:publish)
            put :update, { :commit => 'submit', :artist => { :artist_info => {:bio => @newbio }}}
          end
        end
      end
      context "cancel post with new bio data" do
        before do
          post :update, { :commit => 'cancel', :artist => { :artist_info => {:bio => @newbio }}}
        end
        it "redirects to user page" do
          response.should redirect_to(user_path(artist1))
        end
        it "should have no flash notice" do
          flash[:notice].should be_nil
        end
        it "shouldn't change anything" do
          artist1.bio.should eql @old_bio
        end
      end
      context "update address" do
        before(:each) do
        end
        it "contains flash notice of success" do
          put :update, { :commit => 'submit', :artist => {:artist_info => {:street => '100 main st'}}}
          flash[:notice].should eql "Update successful"
        end
        it "updates user address" do
          put :update, { :commit => 'submit', :artist => {:artist_info => {:street => '100 main st'}}}
          User.find(@logged_in_user.id).artist_info.address.should include '100 main st'
        end
        it 'publishes an update message' do
          Messager.any_instance.should_receive(:publish)
          post :update, { :commit => 'submit', :artist => { :artist_info => {:street => 'wherever' }}}
        end
      end
      context "update os status" do
        it "updates artists os status to true for 201104" do
          put :update, {:commit => 'submit', :artist => {:artist_info => {:os_participation => { '201104' => true }}}}
          response.should be_redirect
          User.find(@logged_in_user.id).os_participation['201104'].should be_true
        end
        it "updates artists os status to true for 201104 given '201104' => 'on'" do
          put :update, { :commit => 'submit', :artist => {:artist_info => {:os_participation => { '201104' => 'on' }}}}
          response.should be_redirect
          User.find(@logged_in_user.id).os_participation['201104'].should be_true
        end
        it "updates artists os status to false for 201104" do
          @logged_in_user.os_participation = {'201104' => 'true'}
          @logged_in_user.save
          put :update, { :commit => 'submit', :artist => {:artist_info => {:os_participation => { '201104' => 'false' }}}}
          User.find(@logged_in_user.id).os_participation['201104'].should be_nil
        end
        it "updates artists os status to true" do
          xhr :put, :update, :artist_os_participation => '1'
          User.find(@logged_in_user.id).os_participation[Conf.oslive.to_s].should be_true
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
          xhr :put, :update, { :commit => 'submit', :artist_os_participation => '0' }
          User.find(@logged_in_user.id).os_participation['201104'].should be_nil
        end
        it "saves an OpenStudiosSignupEvent when the user sets their open studios status to true" do
          FakeWeb.register_uri(:get, Regexp.new( "http:\/\/example.com\/openstudios.*" ), {:status => 200})
          expect {
            xhr :put, :update, { :commit => 'submit', :artist_os_participation => '1' }
          }.to change(OpenStudiosSignupEvent,:count).by(1)
        end

      end
    end
  end

  describe "#edit" do
    context "while not logged in" do
      before do
        get :edit
      end
      it_should_behave_like "redirects to login"
    end
    context "while logged in as someone with no address" do
      render_views
      before do
        login_as(:noaddress)
        @logged_in_user = users(:noaddress)
        @logged_in_artist = users(:noaddress)
        get :edit
      end

      it_should_behave_like "logged in user"
      it_should_behave_like "logged in artist"
      it_should_behave_like "logged in edit page"

      it { response.should be_success }
      it "has the edit form" do
        assert_select("div#artist_edit");
      end
      it 'shows open and close sections for each edit section' do
        assert_select '.open-close-div.acct'
        assert_select '.edit-profile-sxn', :count => (css_select '.open-close-div.acct').count
      end
      it 'shows the open studios section' do
        assert_select '#events', /You need to specify an address or studio/
      end
    end

    context "while logged in" do
      render_views
      before do
        login_as artist1
        @logged_in_user = artist1
        @logged_in_artist = artist1
        get :edit
      end
      it_should_behave_like "logged in user"
      it_should_behave_like "logged in artist"
      it_should_behave_like "logged in edit page"

      it { response.should be_success }

      it "has the edit form" do
        assert_select("div#artist_edit");
      end
      it "has the artists email in the email form input field" do
        assert_select("#info .inner-sxn input#artist_email[value=#{artist1.email}]")
      end
      it "has the website input box with the artists website in it" do
        assert_select("input#artist_url[value=#{artist1.url}]")
      end
      it "has the artists correct links in their respective fields" do
        [:facebook, :blog].each do |k|
          linkval = artist1.send(k)
          linkid = "artist_artist_info_#{k}"
          tag = "input##{linkid}[value=#{linkval}]"
          assert_select(tag)
        end
      end
      it "has the artists' bio textarea field" do
        get :edit
        assert_select("textarea#artist_artist_info_bio", artist1_info.bio)
      end
      it "has heart notification checkbox checked" do
        assert_select 'input#emailsettings_favorites[checked=checked]'
      end
      it 'has a hidden form for donation under the open studios section' do
        assert_select '#paypal_donate_openstudios'
      end
      it 'shows open and close sections for each edit section' do
        assert_select '.open-close-div.acct'
        assert_select '.edit-profile-sxn', :count => (css_select '.open-close-div.acct').count
      end
      it 'shows the open studios section' do
        assert_select '#events', :match => cms_documents(:os_question).article
      end
    end
    context " if email_attrs['favorites'] is false " do
      render_views
      before do
        esettings = artist1.emailsettings
        esettings['favorites'] = false
        artist1.emailsettings = esettings
        artist1.save!
        artist1.reload
        login_as(artist1)
        get :edit
      end
      it "has heart notification checkbox unchecked" do
        assert_select "input#emailsettings_favorites"
        expect(css_select "input#emailsettings_favorites[checked=checked]").to be_empty
      end
    end
  end

  describe "#show" do
    render_views
    context "while not logged in" do
      before(:each) do
        get :show, :id => artist1.id
      end
      it { response.should be_success }
      it 'shows the artists name' do
        assert_select '.artist-profile h1', artist1.get_name(true)
      end
      it "has a twitter share icon it" do
        assert_select '.micro-icon.twitter'
      end
      it "has a facebook share icon on it" do
        assert_select('.micro-icon.facebook')
      end
      it "has a 'favorite' icon on it" do
        assert_select('.micro-icon.heart')
      end
      it 'has thumbnails' do
        assert_select("#bigthumbcolumn")
      end
      it 'has other thumbnails' do
        assert_select('.artist-pieces')
      end
      it 'has the artist\'s bio as the description' do
        assert_select 'head meta[name=description]' do |desc|
          desc.length.should eql 1
          c = desc.first.attributes['content']
          c.should match artist1.bio
          c.should match /^Mission Artists United Artist/
          c.should match artist1.get_name(true)
        end
        assert_select 'head meta[property=og:description]' do |desc|
          desc.length.should eql 1
          c = desc.first.attributes['content']
          c.should include artist1.bio
          c.should match /^Mission Artists United Artist/
          c.should include artist1.get_name(true)
        end
      end
      it 'has the artist\'s (truncated) bio as the description' do
        long_bio = Faker::Lorem.paragraphs(5)
        artist1_info.update_attribute(:bio, long_bio)
        get :show, :id => artist1.id
        assert_select 'head meta[name=description]' do |desc|
          desc.length.should eql 1
          c = desc.first.attributes['content']
          c.should_not eql artist1.bio
          c.should include artist1.bio.to_s[0..420]
          c.should match /\.\.\.$/
          c.should match /^Mission Artists United Artist/
          c.should include artist1.get_name(true)
        end
      end

      it 'displays links to the media' do
        artist = artist1
        tags = artist.tags.map(&:name).map{|t| t[0..255]}
        media = artist.media.map(&:name)

        # fixture validation
        media.should have_at_least(1).medium

        Medium.where(:name => media).each do |med|
          assert_select "a[href=#{medium_path(med)}]", med.name
        end

      end

      it 'has the artist tags and media as the keywords' do
        artist = artist1
        tags = artist.tags.map(&:name).map{|t| t[0..255]}
        media = artist.media.map(&:name)
        expected = tags + media
        assert expected.length > 0, 'Fixture for artist1 needs some tags or media associations'
        assert_select 'head meta[name=keywords]' do |content|
          content.length.should eql 1
          actual = content[0].attributes['content'].split(',').map(&:strip)
          expected.each do |ex|
            actual.should include ex
          end
        end
      end
      it 'has the default keywords' do
        assert_select 'head meta[name=keywords]' do |kws|
          kws.length.should eql 1
          expected = ["art is the mission", "art", "artists", "san francisco"]
          actual = kws[0].attributes['content'].split(',').map(&:strip)
          expected.each do |ex|
            actual.should include ex
          end
        end
      end
    end

    it "reports cannot find artist" do
      get :show, :id => users(:maufan1).id
      assert_select('.rcol .error-msg')
      response.body.should match(/artist you were looking for was not found/)
    end

    context "while logged in" do
      before do
        login_as(artist1)
        @logged_in_user = artist1
        get :show, :id => artist1.id
      end
      it_should_behave_like "logged in user"
      context "looking at your own page" do
        it "website is present" do
          assert_select("div#u_website a[href=#{artist1.url}]")
        end
        it "facebook is present and correct" do
          assert_select("div#u_facebook a[href=#{artist1_info.facebook}]")
        end
        it "has sidebar nav when i look at my page" do
          get :show, :id => artist1.id
          assert_select('#sidebar_nav')
        end
        it "should not have heart icon" do
          expect(css_select(".action-icons .micro-icon.heart")).to be_empty
          assert_select("#sidebar_nav .micro-icon.heart")
        end
        it "should not have extra messaging about email the artist" do
          expect(css_select(".notify-artist")).to be_empty
        end

      end
      context "looking at someone elses page" do
        before(:each) do
          get :show, :id => users(:joeblogs).id
        end
        it_should_behave_like "logged in user"
        it "has a heart icon" do
          assert_select(".micro-icon.heart")
        end
        it 'shows the number of people who have favorited for this artist' do
          assert_select '#num_favorites', 1
        end
        it "has a send message link" do
          assert_select(".notify-artist", :count => 1)
        end
      end
      context "after a user favorites the logged in artist and show the artists page" do
        before do
          @u = users(:quentin)
          @u.add_favorite(artist1)
          login_as(artist1)
          get :show, :id => artist1.id
        end
        it { response.should be_success }
        it "has the user in the 'who favorites me' section" do
          assert_select '#favorites_me div.thumb'
        end
        it "has a link to that users page" do
          assert_select("#favorites_me a[href^=/users/#{@u.id}]")
        end
      end
    end

    context "after an artist favorites another artist and show the artists page" do
      before do
        a = users(:joeblogs)
        artist1.add_favorite(a)
        login_as(artist1)
        get :show, :id => artist1.id
      end
      it { response.should be_success }
      it "shows favorites on show page with links" do
        assert_select("#my_favorites label a[href=#{favorites_user_path(artist1)}]");
      end
    end

    context "while not logged in" do
      before(:each) do
        get :show, :id => artist1.id
      end
      it_should_behave_like "not logged in"
      it "website is present" do
        assert_select("div#u_website a[href=#{artist1.url}]")
      end
      it "has no sidebar nav " do
        expect(css_select('#sidebar_nav')).to be_empty
      end
      it "facebook is present and correct" do
        assert_select("div#u_facebook a[href=#{artist1_info.facebook}]")
      end
    end
    describe 'logged in as admin' do
      before do
        login_as :admin
        get :show, :id => artist1.id
      end
      it_should_behave_like 'returns success'
      it_should_behave_like 'logged in as admin'
    end

    describe 'json' do
      before do
        get :show, :id => artist1.id, :format => 'json'
      end
      it_should_behave_like 'successful json'
    end
  end

  describe 'notify_featured' do
    describe 'unauthorized' do
      it 'not logged in redirects to error' do
        post :notify_featured, :id => artist1.id
        response.should redirect_to '/error'
      end
      it 'logged in as normal redirects to error' do
        login_as :manager
        post :notify_featured, :id => artist1.id
        response.should redirect_to '/error'
      end
    end
    describe 'authorized' do
      before do
        login_as :admin
      end
      it 'returns success' do
        post :notify_featured, :id => artist1.id
        response.should be_success
      end
      it 'calls the notify_featured mailer' do
        ArtistMailer.should_receive(:notify_featured).exactly(:once).and_return(double(:deliver! => true))
        post :notify_featured, :id => artist1.id
      end
    end
  end

  describe 'qrcode' do
    before do
      FileUtils.mkdir_p File.join(Rails.root,'public','artistdata', Artist.first.id.to_s , 'profile')
      FileUtils.mkdir_p File.join(Rails.root,'artistdata', Artist.first.id.to_s , 'profile')
    end
    it 'generates a png if you ask for one' do
      File.stub(:open => double(:read => 'the data from the file'))
      @controller.should_receive(:send_data)
      get :qrcode, :id => Artist.first.id, :format => 'png'
      response.content_type.should eql 'image/png'
    end
    it 'redirects to the png if you ask without format' do
      get :qrcode, :id => Artist.first.id
      response.should redirect_to '/artistdata/' + Artist.first.id.to_s + '/profile/qr.png'
    end
    it 'returns show with flash for an invalid id' do
      get :qrcode, :id => 101
      response.should render_template 'show'
    end
  end

  describe "arrange art for an artist " do
    before do
      # stash an artist and art pieces
      @artpieces = artist1.art_pieces.map(&:id)
    end
    context "while logged in" do
      before(:each) do
        login_as(artist1)
      end
      [[2,1,3], [1,3,2], [2,3,1]].each do |ord|
        it "returns art_pieces in new order #{ord.inspect}" do
          order1 = ord.map{|idx| @artpieces[idx-1]}
          artist1.art_pieces.map(&:id).should_not eql order1
          post :setarrangement, { :neworder => order1.join(",") }
          response.should redirect_to user_url(artist1)
          aps = Artist.find(artist1.id).art_pieces
          aps.map(&:id).should eql order1
          aps[0].artist.representative_piece.id.should==aps[0].id
        end
      end

      it "returns art_pieces in new order (1,3,2)" do
        Messager.any_instance.should_receive(:publish)
        order1 = [ @artpieces[0], @artpieces[2], @artpieces[1] ]
        post :setarrangement, { :neworder => order1.join(",") }
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
    render_views
    describe 'all artists' do
      before do
        get :map
      end
      it_should_behave_like 'one column layout'
      it "returns success" do
        response.should be_success
      end
      it "assigns map" do
        pending "REMOVED GOOGLE MAPS - Once the js is implemented, remove this spec"
        assigns(:map).should be
      end
      it "assigns roster" do
        assigns(:roster).should have_at_least(1).locations
      end
      it "artists should all be active" do
        assigns(:roster).values.flatten.each do |a|
          a.state.should eql 'active'
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
        ArtistsController.any_instance.should_receive(:get_map_info).exactly(assigns(:roster).values.flatten.count).times
        get :map
      end
      it 'renders the map html properly' do
        assert_select "script[src^=https://maps.googleapis.com/maps/api]"
      end
      it 'renders the artists' do
        assigns(:roster).values.flatten.each do |a|
          assert_select "a[href=#{artist_path(a)}]", a.get_name
        end
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
        pending "REMOVED GOOGLE MAPS - Once the js is implemented, remove this spec"
        assigns(:map).should be_true
      end
      it "assigns roster" do
        assigns(:roster).should have_at_least(1).locations
      end
      it "artists should all be active" do
        assigns(:roster).values.flatten.each do |a|
          a.state.should eql 'active'
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
    describe 'logged in as admin' do
      before do
        login_as :admin
        get :map
      end
      it_should_behave_like 'returns success'
      it_should_behave_like 'logged in as admin'
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
        login_as(artist1)
        get :admin_index
      end
      it "should report error" do
        response.should redirect_to '/error'
      end
    end
    context "logged in as admin" do
      render_views
      before do
        ArtistInfo.any_instance.stub(:os_participation => {'201204' => true})
        Artist.any_instance.stub(:os_participation => {'201204' => true})

        login_as :admin
        get :admin_index
      end
      it_should_behave_like 'logged in as admin'
      it "returns success" do
        response.should be_success
      end
      it "renders sort by links" do
        assert_select('.sortby a', :count => 14)
      end
      it 'renders a csv export link' do
        assert_select('a.export-csv button', /export/)
      end
      it 'renders an update os status button' do
        assert_select('button.update-artists', /update os status/)
      end
      it 'renders controls for hiding rows' do
        assert_select('.hide-rows .row-info');
      end
      it 'renders .pending rows for all pending artists' do
        assert_select('tr.pending', :count => Artist.all.select{|s| s.state == 'pending'}.count)
      end
      it 'renders .suspended rows for all suspended artists' do
        assert_select('tr.suspended', :count => Artist.all.select{|s| s.state == 'suspended'}.count)
      end
      it 'renders .deleted rows for all deleted artists' do
        assert_select('tr.deleted', :count => Artist.all.select{|s| s.state == 'deleted'}.count)
      end
      it 'renders created_at date for all pending artists' do
        Artist.all.select{|s| s.state == 'pending'}.each do |a|
          assert_select('tr.pending td', /#{a.created_at.strftime('%m/%d/%y')}/)
        end
      end
      it 'renders .participating rows for all pending artists' do
        assert_select('tr.participating', :count => Artist.all.select{|a| a.os_participation['201210']}.count)
      end
      it 'renders activation link for inactive artists' do
        assert_select('.activation_link', :count => Artist.all.select{|s| s.state == 'pending'}.count)
        assert_select('.activation_link', /http:\/\/#{Conf.site_url}\/activate\/#{users(:pending_artist).activation_code}/)
      end
      it 'renders forgot link if there is a reset code' do
        assert_select('.forgot_password_link', :count => Artist.all.select{|s| s.reset_code.present?}.count)
        assert_select('.forgot_password_link', /http:\/\/#{Conf.site_url}\/reset\/#{users(:reset_password).reset_code}/)
      end
    end
  end

  describe '#suggest' do
    before do
      get :suggest, :input => 'jes'
    end
    it_should_behave_like 'successful json'
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
      j.first['value'].should eql 'jesse ponce'
    end
  end

  describe "- named routes" do
    describe 'collection paths' do
      [:destroyart, :arrangeart, :thumbs, :setarrangement, :deleteart].each do |path|
        it "should have #{path} as artists collection path" do
          eval('%s_artists_path.should eql \'/artists/%s\'' % [path,path])
        end
      end
    end
    describe 'member paths' do
      [:bio].each do |path|
        it "should have #{path} as an artist member path" do
          a = Artist.first
          send("#{path}_artist_path", a).should eql "/artists/#{a.id}/#{path}"
        end
      end
    end
  end

end
