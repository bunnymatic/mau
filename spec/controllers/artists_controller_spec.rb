require 'spec_helper'
require 'htmlentities'
include AuthenticatedTestHelper

describe ArtistsController do

  fixtures :users, :roles_users,  :roles, :artist_infos, :art_pieces,
    :studios, :media, :art_piece_tags, :art_pieces_tags, :cms_documents

  before do
    Rails.cache.stub(:read => nil)
  end

  let(:artist1) { users(:artist1) }
  let(:artist1_info) { artist1.artist_info }
  let(:ne_bounds) { Artist::BOUNDS['NE'] }
  let(:sw_bounds) { Artist::BOUNDS['SW'] }

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
      it "builds a presenter with only active artists" do
        presenter = assigns(:gallery)
        expect( presenter ).to be_a_kind_of ArtistsGallery
        expect( presenter.items).to have_at_least(2).artists
        expect( presenter.items.select{|artist| !artist.active?} ).to be_empty
      end
      it "set the title" do
        assigns(:page_title).should eql 'Mission Artists United - MAU Artists'
      end
      it "thumbs have representative art pieces in them" do
        presenter = assigns(:gallery)
        presenter.items.each do |a|
          rep = a.representative_piece
          assert_select(".allthumbs .thumb .name", /#{a.name}/);
          assert_select(".allthumbs .thumb[pid=#{rep.id}] img[src*=#{rep.filename}]")
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
      get :roster
    end
    it_should_behave_like 'one column layout'
    it { response.should be_success }
    it "assigns artists" do
      assigns(:roster).artists.length.should have_at_least(2).artists
    end
    it "set the title" do
      assigns(:page_title).should eql 'Mission Artists United - MAU Artists'
    end
    it "artists are all active" do
      assigns(:roster).artists.each do |a|
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
      let(:old_bio) { artist1_info.bio }
      let(:new_bio) { "this is the new bio" }
      let(:artist_info_attrs) { { :bio => new_bio } }
      before do
        @logged_in_user = login_as(artist1)
      end
      context "submit" do
        context "post with new bio data" do
          it "redirects to to edit page" do
            put :update, { :commit => 'submit', :artist => { :artist_info => artist_info_attrs}}
            flash[:notice].should eql 'Update successful'
            response.should redirect_to(edit_artist_path(artist1))
          end
          it 'publishes an update message' do
            Messager.any_instance.should_receive(:publish)
            put :update, { :commit => 'submit', :artist => { :artist_info => artist_info_attrs}}
          end
        end
      end
      context "cancel post with new bio data" do
        before do
          post :update, { :commit => 'cancel', :artist => { :artist_info => artist_info_attrs}}
        end
        it "redirects to user page" do
          response.should redirect_to(user_path(artist1))
        end
        it "should have no flash notice" do
          flash[:notice].should be_nil
        end
        it "shouldn't change anything" do
          artist1.bio.should eql old_bio
        end
      end
      context "update address" do
        let(:artist_info_attrs) { { :street => '100 main st' } }
        let(:street) { artist_info_attrs[:street] }
        before(:each) do
        end
        it "contains flash notice of success" do
          put :update, { :commit => 'submit', :artist => {:artist_info => artist_info_attrs}}
          flash[:notice].should eql "Update successful"
        end
        it "updates user address" do
          put :update, { :commit => 'submit', :artist => {:artist_info => artist_info_attrs}}
          artist1_info.reload.address.should include street
        end
        it 'publishes an update message' do
          Messager.any_instance.should_receive(:publish)
          post :update, { :commit => 'submit', :artist => { :artist_info => {:street => 'wherever' }}}
        end
      end
      context "update os status" do
        it "updates artists os statuss to true for 201104" do
          put :update, :commit => 'submit', :artist => {
            :artist_info => {
              :os_participation => { '201104' => true }
            }
          }
          response.should be_redirect
          artist1.reload.os_participation['201104'].should be_true
        end
        it "updates artists os status to true for 201104 given '201104' => 'on'" do
          put :update, :commit => 'submit', :artist => {
            :artist_info => {
              :os_participation => { '201104' => 'on' }
            }
          }
          response.should be_redirect
          artist1.reload.os_participation['201104'].should be_true
        end
        it "updates artists os status to false for 201104" do
          @logged_in_user.os_participation = {'201104' => 'true'}
          @logged_in_user.save
          put :update, :commit => 'submit', :artist => {
            :artist_info => {
              :os_participation => { '201104' => 'false' }
            }
          }
          artist1.reload.os_participation['201104'].should be_nil
        end
        it "updates artists os status to true" do
          xhr :put, :update, :artist_os_participation => '1'
          artist1.reload.os_participation[Conf.oslive.to_s].should be_true
        end

        it "sets false if artist has no address" do
          ai = @logged_in_user.artist_info
          ai.update_attributes({ :lat => nil,
                                 :lng => nil,
                                 :street => '',
                                 :city => '',
                                 :addr_state => '',
                                 :zip => '',
                                 :open_studios_participation => '' })

          @logged_in_user.update_attribute(:studio_id,0)
          @logged_in_user.reload
          xhr :put, :update, { :commit => 'submit', :artist_os_participation => '0' }
          artist1.reload.os_participation['201104'].should be_nil
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
        long_bio = Faker::Lorem.paragraphs(5).join
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
    let(:file_double) {
      double(:read => 'the data from the file', :write => nil, :close => nil, :binmode => true)
    }
    before do
      MojoMagick.stub(:raw_command).and_return(true)
      FileUtils.mkdir_p File.join(Rails.root,'public','artistdata', Artist.first.id.to_s , 'profile')
      FileUtils.mkdir_p File.join(Rails.root,'artistdata', Artist.first.id.to_s , 'profile')
    end
    it 'generates a png if you ask for one' do
      File.stub(:open => file_double)
      @controller.stub(:render)
      @controller.should_receive(:send_data)
      get :qrcode, :id => Artist.first.id, :format => 'png'
      response.content_type.should eql 'image/png'
    end
    it 'redirects to the png if you ask without format' do
      File.stub(:open => file_double)
      @controller.stub(:render)
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
        get :map_page
      end
      it_should_behave_like 'one column layout'
      it "returns success" do
        response.should be_success
      end
      it "sets up a presenter" do
        assigns(:map_info).should be_a_kind_of ArtistsMap
      end
      it 'puts the map data as json on the page' do
        response.body.should match /MAU.map_markers = \[\{/
      end
      it "artists should all be active" do
        assigns(:map_info).with_addresses.each do |a|
          a.state.should eql 'active'
        end
      end
      it "roster does not include artists outside of 'the mission'" do
        roster = assigns(:map_info).with_addresses.each do |a|
          lat,lng = a.address_hash[:latlng]
          (sw_bounds[0] < lat && lat < ne_bounds[0]).should be_true, "Latitude #{lat} is not within bounds"
          (sw_bounds[1] < lng && lng < ne_bounds[1]).should be_true ,"Longitude #{lng} is not within bounds"
        end
      end
      it 'renders the map html properly' do
        assert_select "script[src^=//maps.google.com/maps/api/js]"
      end
      it 'renders the artists' do
        assigns(:map_info).with_addresses.each do |a|
          assert_select "a[href=#{artist_path(a)}]", a.get_name
        end
      end
    end
    describe 'os only' do
      before do
        get :map_page, "osonly" => true
      end
      it "returns success" do
        response.should be_success
      end
      it "sets up a presenter" do
        assigns(:map_info).should be_a_kind_of ArtistsMap
      end
      it 'puts the map data as json on the page' do
        response.body.should match /MAU.map_markers = \[\{/
      end
      it "artists should all be active" do
        assigns(:map_info).with_addresses.each do |a|
          a.state.should eql 'active'
        end
      end

      it "roster does not include artists outside of 'the mission'" do
        roster = assigns(:map_info).with_addresses.each do |a|
          lat,lng = a.address_hash[:latlng]

          (sw_bounds[0] < lat && lat < ne_bounds[0]).should be_true, "Latitude #{lat} is not within bounds"
          (sw_bounds[1] < lng && lng < ne_bounds[1]).should be_true ,"Longitude #{lng} is not within bounds"
        end
      end
    end
    describe 'logged in as admin' do
      before do
        login_as :admin
        get :map_page
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
      before do
        login_as :admin
      end
      context 'with no params' do
        render_views
        before do
          ArtistInfo.any_instance.stub(:os_participation => {'201204' => true})
          Artist.any_instance.stub(:os_participation => {'201204' => true})

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
          assert_select('tr.pending', :count => Artist.pending.count)
        end
        it 'renders .suspended rows for all suspended artists' do
          assert_select('tr.suspended', :count => Artist.all.select{|s| s.state == 'suspended'}.count)
        end
        it 'renders .deleted rows for all deleted artists' do
          assert_select('tr.deleted', :count => Artist.all.select{|s| s.state == 'deleted'}.count)
        end
        it 'renders created_at date for all pending artists' do
          Artist.all.select{|s| s.state == 'pending'}.each do |a|
            expected_match = a.created_at.strftime("%m/%d/%y")
            assert_select('tr.pending td', /#{expected_match}/)
          end
        end
        it 'renders .participating rows for all pending artists' do
          assert_select('tr.participating', :count => Artist.all.select{|a| a.os_participation['201210']}.count)
        end
        it 'renders activation link for inactive artists' do
          activation_url = activate_url(:activation_code => users(:pending_artist).activation_code)
          assert_select('.activation_link', :count => Artist.all.select{|s| s.state == 'pending'}.count)
          assert_select('.activation_link', :match => activation_url )
        end
        it 'renders forgot link if there is a reset code' do
          assert_select('.forgot_password_link', :count => Artist.all.select{|s| s.reset_code.present?}.count)
          assert_select('.forgot_password_link', :match => reset_url(:reset_code => users(:reset_password).reset_code))
        end
      end
      context "with sort_by" do
        it 'sorts by lastname' do
          get :admin_index, 'sortby' => 'lastname'
          assigns(:artists).map{|a| a.lastname.downcase}.should be_monotonically_increasing
        end
        it 'sorts by lastname' do
          get :admin_index, 'rsortby' => 'lastname'
          assigns(:artists).map{|a| a.lastname.downcase}.should be_monotonically_decreasing
        end
        it 'sorts by login' do
          get :admin_index, 'sortby' => 'login'
          assigns(:artists).map{|a| a.login.downcase}.should be_monotonically_increasing
        end
        it 'sorts by login' do
          get :admin_index, 'rsortby' => 'login'
          assigns(:artists).map{|a| a.login.downcase}.should be_monotonically_decreasing
        end
      end

      render_views
      it 'returns a csv' do
        get :admin_index, 'format' => 'csv'
        response.should be_csv_type
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

  describe '#by_lastname' do
    before { get :by_lastname }
    it { response.should redirect_to root_path }
  end

  describe '#by_firstname' do
    before { get :by_firstname }
    it { response.should redirect_to root_path }
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
