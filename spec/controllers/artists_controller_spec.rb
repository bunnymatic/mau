require 'spec_helper'
require 'htmlentities'

describe ArtistsController do

  let(:admin) { FactoryGirl.create(:artist, :admin) }
  let(:artist) { FactoryGirl.create(:artist, :with_studio, :with_art) }
  let(:artist2) { FactoryGirl.create(:artist, :with_studio) }
  let(:artist_with_tags) { FactoryGirl.create(:artist, :with_studio, :with_art, :with_tagged_art) }
  let(:without_address) { FactoryGirl.create(:artist, :active, :with_no_address) }
  let(:artists) do
    [artist] + FactoryGirl.create_list(:artist, 3, :with_studio, :with_tagged_art)
  end

  let(:fan) { FactoryGirl.create(:fan, :active) }
  let(:artist_info) { artist.artist_info }
  let(:ne_bounds) { Artist::BOUNDS['NE'] }
  let(:sw_bounds) { Artist::BOUNDS['SW'] }

  describe "#index" do
    before do
      artists
    end
    describe 'logged in as admin' do
      render_views
      before do
        login_as admin
        get :index
      end
      it { expect(response).to be_success }
      it_should_behave_like 'logged in as admin'
    end


    describe 'html' do
      render_views
      before do
        get :index
      end
      it { expect(response).to be_success }
      it "builds a presenter with only active artists" do
        presenter = assigns(:gallery)
        expect( presenter ).to be_a_kind_of ArtistsGallery
        expect( presenter.items).to have_at_least(2).artists
        expect( presenter.items.select{|artist| !artist.active?} ).to be_empty
      end
      it "set the title" do
        assigns(:page_title).should eql 'Mission Artists United - MAU Artists'
      end
    end

    describe 'json' do
      before do
        get :index, format: 'json'
      end
      it_should_behave_like 'successful json'
      it 'returns all active artists' do
        j = JSON.parse(response.body)
        j.count.should eql Artist.active.count
      end
    end

    describe 'xhr' do
      before do
        get :index, p: '0', filter: filter
      end
      context 'without filter' do
        let(:filter) { '' }
        it { expect(response).to be_success }
        it { expect(assigns(:gallery).pagination.items).to have_at_least(1).artist }
      end
      context 'with filter' do
        let(:filter) { 'thisfilterbetternotmatchanything' }
        it { expect(response).to be_success }
        it { expect(assigns(:gallery).pagination.items).to be_empty }
      end
    end
  end

  describe '#index roster view' do
    render_views
    before do
      get :roster
    end
    it { expect(response).to be_success }
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
  describe "#update", eventmachine: true do
    render_views
    before do
      artist_info.update_attribute(:open_studios_participation,'')
    end
    context "while not logged in" do
      context "with invalid params" do
        before do
          put :update, id: artist.id, user: {}
        end
        it_should_behave_like "redirects to login"
      end
      context "with valid params" do
        before do
          put :update, id: artist.id, user: { firstname: 'blow' }
        end
        it_should_behave_like "redirects to login"
      end
    end
    context "while logged in" do
      let(:old_bio) { artist_info.bio }
      let(:new_bio) { "this is the new bio" }
      let(:artist_info_attrs) { { bio: new_bio } }
      before do
        @logged_in_user = login_as(artist, record: true)
      end
      context "submit" do
        context "post with new bio data" do
          it "redirects to to edit page" do
            put :update, id: artist, commit: 'submit', artist: { artist_info: artist_info_attrs}
            flash[:notice].should eql 'Update successful'
            expect(response).to redirect_to(edit_artist_path(artist))
          end
          it 'publishes an update message' do
            Messager.any_instance.should_receive(:publish)
            put :update, id: artist, commit: 'submit', artist: { artist_info: artist_info_attrs}
          end
        end
      end
      context "cancel post with new bio data" do
        before do
          post :update, id: artist, commit: 'cancel', artist: { artist_info: artist_info_attrs}
        end
        it "redirects to user page" do
          expect(response).to redirect_to(user_path(artist))
        end
        it "should have no flash notice" do
          flash[:notice].should be_nil
        end
        it "shouldn't change anything" do
          artist.bio.should eql old_bio
        end
      end
      context "update address" do
        let(:artist_info_attrs) { { street: '100 main st' } }
        let(:street) { artist_info_attrs[:street] }

        it "contains flash notice of success" do
          put :update, id: artist, commit: 'submit', artist: {artist_info: artist_info_attrs}
          flash[:notice].should eql "Update successful"
        end
        it "updates user address" do
          put :update, id: artist, commit: 'submit', artist: {artist_info: artist_info_attrs}
          artist_info.reload.address.should include street
        end
        it 'publishes an update message' do
          Messager.any_instance.should_receive(:publish)
          put :update, id: artist, commit: 'submit', artist: { artist_info: {street: 'wherever' }}
        end
      end
      context "update os status" do
        before do
          FactoryGirl.create(:open_studios_event)
        end
        it "updates artists os status to true" do
          xhr :put, :update, id: artist, artist: { "os_participation" => '1' }
          artist.reload.os_participation[OpenStudiosEvent.current.key].should be_true
        end

        it "sets false if artist has no address" do
          xhr :put, :update, id: without_address, commit: 'submit', artist: { "os_participation" => '1' }
          without_address.reload.os_participation[OpenStudiosEvent.current.key].should be_nil
        end
        it "saves an OpenStudiosSignupEvent when the user sets their open studios status to true" do
          stub_request(:get, Regexp.new( "http:\/\/example.com\/openstudios.*" ))
          expect {
            xhr :put, :update, id: artist, commit: 'submit', artist: { "os_participation" => '1' }
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
    context 'while logged in as a fan' do
      before do
        login_as fan
        get :edit
      end
      it { should redirect_to edit_user_path(fan) }
    end
    context "while logged in as someone with no address" do
      render_views
      before do
        login_as without_address
        @logged_in_user = without_address
        @logged_in_artist = without_address
        get :edit
      end

      it_should_behave_like "logged in user"
      it_should_behave_like "logged in artist"
      it_should_behave_like "logged in edit page"

      it { expect(response).to be_success }
      it "has the edit form" do
        assert_select("div#artist_edit");
      end
      it 'shows open and close sections for each edit section' do
        assert_select '.open-close-div.acct'
        assert_select '.edit-profile-sxn', count: (css_select '.open-close-div.acct').count
      end
      it 'shows the open studios section' do
        assert_select '#events', /You need to specify an address or studio/
      end
    end

    context "while logged in" do
      render_views
      before do
        artist.artist_info.update_attributes({facebook: 'example.com/facebooklink', blog: 'example.com/bloglink'})
        login_as artist
        @logged_in_user = artist
        @logged_in_artist = artist
        get :edit
      end
      it_should_behave_like "logged in user"
      it_should_behave_like "logged in artist"
      it_should_behave_like "logged in edit page"

      it { expect(response).to be_success }

      it "has the edit form" do
        assert_select("div#artist_edit");
      end
      it "has the artists email in the email form input field" do
        assert_select("#info .inner-sxn input#artist_email[value=#{artist.email}]")
      end
      it "has the website input box with the artists website in it" do
        assert_select("input#artist_url[value=#{artist.url}]")
      end
      it "has the artists correct links in their respective fields" do
        [:facebook, :blog].each do |k|
          linkval = artist.send(k)
          linkid = "artist_artist_info_#{k}"
          tag = "input##{linkid}[value=#{linkval}]"
          assert_select(tag)
        end
      end
      it "has the artists' bio textarea field" do
        assert_select("textarea#artist_artist_info_bio", artist_info.bio)
      end
      it "has heart notification checkbox checked" do
        assert_select 'input#emailsettings_favorites[checked=checked]'
      end
      it 'has a hidden form for donation under the open studios section' do
        assert_select '#paypal_donate_openstudios'
      end
      it 'shows open and close sections for each edit section' do
        assert_select '.open-close-div.acct'
        assert_select '.edit-profile-sxn', count: (css_select '.open-close-div.acct').count
      end
      it 'shows the open studios section' do
        assert_select '#events'
      end
    end
    context " if email_attrs['favorites'] is false " do
      render_views
      before do
        esettings = artist.emailsettings
        esettings['favorites'] = false
        artist.emailsettings = esettings
        artist.save!
        artist.reload
        login_as(artist)
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
    it 'when looking for a suspended artist' do
      artist.update_attribute('state', 'suspended')
      get :show, id: artist.id
      expect(response).to render_template 'show'
      expect(flash[:error]).to be_present
    end

    context "while not logged in" do
      before(:each) do
        get :show, id: artist_with_tags.id
      end
      it { expect(response).to be_success }
      it 'shows the artists name' do
        assert_select '.artist-profile h1', artist_with_tags.get_name(true)
      end
      it "has a twitter share icon it" do
        assert_select '.ico-twitter'
      end
      it "has a facebook share icon on it" do
        assert_select('.ico-facebook')
      end
      it "has a 'favorite' icon on it" do
        assert_select('.ico-heart')
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
          c.should match artist_with_tags.bio[0..50]
          c.should match /^Mission Artists United Artist/
          c.should match artist_with_tags.get_name(true)
        end
        assert_select 'head meta[property=og:description]' do |desc|
          desc.length.should eql 1
          c = desc.first.attributes['content']
          c.should include artist_with_tags.bio[0..50]
          c.should match /^Mission Artists United Artist/
          c.should include artist_with_tags.get_name(true)
        end
      end
      it 'has the artist\'s (truncated) bio as the description' do
        long_bio = Faker::Lorem.paragraphs(15).join
        artist_info.update_attribute(:bio, long_bio)
        get :show, id: artist.id
        assert_select 'head meta[name=description]' do |desc|
          desc.length.should eql 1
          c = desc.first.attributes['content']
          c.should_not eql artist.bio
          c.should include artist.bio.to_s[0..420]
          c.should match /\.\.\.$/
          c.should match /^Mission Artists United Artist/
          c.should include artist.get_name(true)
        end
      end

      it 'displays links to the media' do
        tags = artist_with_tags.tags.map(&:name).map{|t| t[0..255]}
        media = artist_with_tags.media.map(&:name)

        # fixture validation
        media.should have_at_least(1).medium

        Medium.where(name: media).each do |med|
          assert_select "a[href=#{medium_path(med)}]", med.name
        end

      end

      it 'has the artist tags and media as the keywords' do
        tags = artist_with_tags.tags.map(&:name).map{|t| t[0..255]}
        media = artist_with_tags.media.map(&:name)
        expected = tags + media
        assert expected.length > 0, 'Fixture for artist needs some tags or media associations'
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
      get :show, id: fan.id
      assert_select('.rcol .error-msg')
      response.body.should match(/unable to find the artist/)
    end

    context "while logged in" do
      before do
        login_as(artist)
        @logged_in_user = artist
      end

      context "looking at your own page" do
        before do
          artist.artist_info.update_attribute(:facebook, "http://www.facebook.com/#{artist.login}")
          get :show, id: artist.id
        end
        it_should_behave_like "logged in user"
        it "website is present" do
          assert_select("div#u_website a[href=#{artist.url}]")
        end
        it "facebook is present and correct" do
          assert_select("div#u_facebook a[href=#{artist_info.facebook}]")
        end
        it "has sidebar nav when i look at my page" do
          get :show, id: artist.id
          assert_select('#sidebar_nav')
        end
        it "should not have heart icon" do
          expect(css_select(".action-icons .ico-heart")).to be_empty
          assert_select("#sidebar_nav .ico-heart")
        end
        it "should not have extra messaging about email the artist" do
          expect(css_select(".notify-artist")).to be_empty
        end
      end
      context "looking at someone elses page" do
        before(:each) do
          get :show, id: artist2.id
        end
        it_should_behave_like "logged in user"
        it "has a heart icon" do
          assert_select(".ico-heart")
        end
        it "has a send message link" do
          assert_select(".notify-artist", count: 1)
        end
      end
      context "after a user favorites the logged in artist and show the artists page" do
        before do
          artist2.add_favorite(artist)
          get :show, id: artist.id
        end
        it { expect(response).to be_success }
        it "has the user in the 'who favorites me' section" do
          assert_select '#favorites_me div.thumb'
        end
        it "has a link to that users page" do
          assert_select("#favorites_me a[href^=/users/#{artist2.id}]")
        end
      end
    end

    context "after an artist favorites another artist and show the artists page" do
      before do
        artist.add_favorite(artist2)
        login_as(artist)
        get :show, id: artist.id
      end
      it { expect(response).to be_success }
      it "shows favorites on show page with links" do
        assert_select("#my_favorites label a[href=#{favorites_user_path(artist)}]");
      end
    end

    context "while not logged in" do
      before(:each) do
        artist.artist_info.update_attribute(:facebook, "http://www.facebook.com/#{artist.login}")
        get :show, id: artist.id
      end
      it_should_behave_like "not logged in"
      it "website is present" do
        assert_select("div#u_website a[href=#{artist.url}]")
      end
      it "has no sidebar nav " do
        expect(css_select('#sidebar_nav')).to be_empty
      end
      it "facebook is present and correct" do
        assert_select("div#u_facebook a[href=#{artist_info.facebook}]")
      end
    end
    describe 'logged in as admin' do
      before do
        login_as admin
        get :show, id: artist.id
      end
      it { expect(response).to be_success }
      it_should_behave_like 'logged in as admin'
    end

    describe 'json' do
      before do
        get :show, id: artist.id, format: 'json'
      end
      it_should_behave_like 'successful json'
    end
  end

  describe 'qrcode' do
    let(:file_double) {
      double(read: 'the data from the file', write: nil, close: nil, binmode: true)
    }
    before do
      MojoMagick.stub(:raw_command).and_return(true)
      FileUtils.mkdir_p File.join(Rails.root,'public','artistdata', artist.id.to_s , 'profile')
      FileUtils.mkdir_p File.join(Rails.root,'artistdata', artist.id.to_s , 'profile')
    end
    it 'generates a png if you ask for one' do
      File.stub(open: file_double)
      @controller.stub(:render)
      @controller.should_receive(:send_data)
      get :qrcode, id: artist.id, format: 'png'
      response.content_type.should eql 'image/png'
    end
    it 'redirects to the png if you ask without format' do
      File.stub(open: file_double)
      @controller.stub(:render)
      get :qrcode, id: artist.id
      expect(response).to redirect_to '/artistdata/' + artist.id.to_s + '/profile/qr.png'
    end
    it 'returns show with flash for an invalid id' do
      get :qrcode, id: 101
      expect(response).to render_template 'show'
    end
    it 'returns show with flash if the artist has been deleted' do
      artist.update_attribute(:state, 'deleted')
      get :qrcode, id: artist.id
      expect(flash[:error]).to be_present
    end
    it 'returns show with flash if the artist has been suspended' do
      artist.update_attribute(:state, 'suspended')
      get :qrcode, id: artist.id
      expect(flash[:error]).to be_present
    end
  end

  describe "#setarrangement", eventmachine: true do
    before do
      # stash an artist and art pieces
      @artpieces = artist.art_pieces.map(&:id)
    end
    context "while logged in" do
      before(:each) do
        login_as(artist)
      end
      [[2,1,3], [1,3,2], [2,3,1]].each do |ord|
        it "returns art_pieces in new order #{ord.inspect}" do
          order1 = ord.map{|idx| @artpieces[idx-1]}
          artist.art_pieces.map(&:id).should_not eql order1
          post :setarrangement, { neworder: order1.join(",") }
          expect(response).to redirect_to user_url(artist)
          aps = Artist.find(artist.id).art_pieces
          aps.map(&:id).should eql order1
          aps[0].artist.representative_piece.id.should==aps[0].id
        end
      end

      it "publishes a message to the Messager that something happened" do
        Messager.any_instance.should_receive(:publish)
        order1 = [ @artpieces[0], @artpieces[2], @artpieces[1] ]
        post :setarrangement, { neworder: order1.join(",") }
      end

      it "sets a flash with invalid params" do
        post :setarrangement
        expect(response).to redirect_to(user_path(artist))
        flash[:error].should be_present
      end

      it 'does not rearrange art if cancel is pressed' do
        order1 = artist.art_pieces.map(&:id)
        post :setarrangement, {  neworder: [order1.last] + order1[0..-2], submit: 'cancel' }
        expect(artist.art_pieces.map(&:id)).to eql order1

      end

    end
  end

  describe '#arrange_art' do
    before do
      login_as artist
      get :arrange_art
    end
    it 'sets artist' do
      expect(assigns(:artist)).to be_a_kind_of ArtistPresenter
      expect(assigns(:artist).artist).to eql artist
    end
  end

  describe '#delete_art' do
    before do
      login_as artist
      get :delete_art
    end
    it 'sets artist' do
      expect(assigns(:artist)).to be_a_kind_of ArtistPresenter
      expect(assigns(:artist).artist).to eql artist
    end
  end

  describe "- logged out" do
    context "post to set arrangement" do
      before do
        post :setarrangement, { neworder: "1,2" }
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
      it { expect(response).to be_success }
      it "sets up a presenter" do
        assigns(:map_info).should be_a_kind_of ArtistsMap
      end
      it 'puts the map data as json on the page' do
        expect(response.body).to have_css 'script', text: /MAU.map_markers\s+/, visible: false
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
          assert_select "a[href=#{artist_path(a.artist)}]", a.get_name
        end
      end
    end
    describe 'os only' do
      before do
        get :map_page, "osonly" => true
      end
      it { expect(response).to be_success }
      it "sets up a presenter" do
        assigns(:map_info).should be_a_kind_of ArtistsMap
      end
      it 'puts the map data as json on the page' do
        expect(response.body).to have_css 'script', text: /MAU.map_markers\s+/, visible: false
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
        login_as admin
        get :map_page
      end
      it { expect(response).to be_success }
      it_should_behave_like 'logged in as admin'
    end
  end

  describe '#destroyart', eventmachine: true do
    let(:art_pieces) { ArtPiece.all.reject{|art| art.artist == artist} }
    let(:art_pieces_for_deletion) {
      Hash[art_pieces.map.with_index{|a,idx| [a.id, idx % 2]}]
    }
    let(:destroy_params) { {art: art_pieces_for_deletion} }
    let(:num_to_dump) { art_pieces_for_deletion.values.select{|v| v==1}.count }
    before do
      artist_with_tags
      login_as artist
      post :destroyart
    end
    it 'validate fixtures' do
      expect(art_pieces).to have_at_least(2).pieces
    end
    it{ expect(response).to redirect_to artist_path(artist) }

    context 'when trying to destroy art that is not yours' do
      it{ expect(response).to redirect_to artist_path(artist) }
      it "should not remove art" do
        expect{
          post :destroyart, destroy_params
        }.to_not change(ArtPiece, :count)
      end

    end

    context 'when trying to destroy art that is yours' do
      let(:art_pieces) { artist.art_pieces }
      it 'validate fixtures' do
        expect(art_pieces).to have_at_least(2).pieces
      end
      it{ expect(response).to redirect_to artist_path(artist) }
      it "should remove art" do
        expect{
          post :destroyart, destroy_params
        }.to change(ArtPiece, :count).by(-1*num_to_dump)
      end

    end

  end

  describe '#suggest' do
    before do
      get :suggest, q: artist.firstname[0..2]
    end
    it_should_behave_like 'successful json'
    it 'returns a hash with a list of artists' do
      j = JSON.parse(response.body)
      j.should be_a_kind_of Array
      (j.first.has_key? 'info').should be
      (j.first.has_key? 'value').should be
    end
    it 'list of artists matches the input parameter' do
      j = JSON.parse(response.body)
      j.should be_a_kind_of Array
      j.should have(1).artist_name
      j.first['value'].should eql artist.get_name
    end
  end

  describe '#by_lastname' do
    before { get :by_lastname }
    it { expect(response).to redirect_to root_path }
  end

  describe '#by_firstname' do
    before { get :by_firstname }
    it { expect(response).to redirect_to root_path }
  end

  describe "- named routes" do
    describe 'collection paths' do
      [:destroyart, :arrange_art, :thumbs, :setarrangement, :delete_art].each do |path|
        it "should have #{path} as artists collection path" do
          eval('%s_artists_path.should eql \'/artists/%s\'' % [path,path])
        end
      end
    end
    describe 'member paths' do
      [:bio].each do |path|
        it "should have #{path} as an artist member path" do
          send("#{path}_artist_path", artist).should eql "/artists/#{artist.id}/#{path}"
        end
      end
    end
  end

end
