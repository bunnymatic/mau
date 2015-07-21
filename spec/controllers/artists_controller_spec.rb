require 'spec_helper'
require 'htmlentities'

describe ArtistsController do

  let(:admin) { FactoryGirl.create(:artist, :admin) }
  let(:artist) { FactoryGirl.create(:artist, :with_studio, :with_art, nomdeplume: nil, firstname: 'joe', lastname: 'ablow') }
  let(:artist2) { FactoryGirl.create(:artist, :with_studio) }
  let(:artist_with_tags) { FactoryGirl.create(:artist, :with_studio, :with_art, :with_tagged_art, firstname: 'Bill', lastname: "O'Tagman") }
  let(:without_address) { FactoryGirl.create(:artist, :active, :with_no_address) }
  let(:artists) do
    [artist] + FactoryGirl.create_list(:artist, 3, :with_studio, :with_tagged_art)
  end
  let!(:open_studios_event) { create(:open_studios_event) }
  let(:fan) { FactoryGirl.create(:fan, :active) }
  let(:artist_info) { artist.artist_info }
  let(:ne_bounds) { Artist::BOUNDS['NE'] }
  let(:sw_bounds) { Artist::BOUNDS['SW'] }

  describe "#index" do
    before do
      artists
    end

    describe 'html' do
      before do
        get :index
      end
      it { expect(response).to be_success }
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
        get :index, p: '0', l: 'a'
      end
      it { expect(response).to be_success }
      it { expect(assigns(:gallery).pagination.items).to have_at_least(1).artist }
    end
  end

  describe '#index roster view' do
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
        login_as(artist, record: true)
      end
      context "submit" do
        context "post with new bio data" do
          it "redirects to to edit page" do
            put :update, id: artist, commit: 'submit', artist: { artist_info_attributes: artist_info_attrs}
            expect(flash[:notice]).to eql "Your profile has been updated"
            expect(response).to redirect_to(edit_artist_path(artist))
          end
          it 'publishes an update message' do
            Messager.any_instance.should_receive(:publish)
            put :update, id: artist, commit: 'submit', artist: { artist_info_attributes: artist_info_attrs}
          end
        end
      end
      context "cancel post with new bio data" do
        before do
          post :update, id: artist, commit: 'cancel', artist: { artist_info_attributes: artist_info_attrs}
        end
        it "redirects to user page" do
          expect(response).to redirect_to(user_path(artist))
        end
        it "should have no flash notice" do
          expect(flash[:notice]).to be_nil
        end
        it "shouldn't change anything" do
          artist.bio.should eql old_bio
        end
      end
      context "update address" do
        let(:artist_info_attrs) { { street: '100 main st' } }
        let(:street) { artist_info_attrs[:street] }

        it "contains flash notice of success" do
          put :update, id: artist, commit: 'submit', artist: {artist_info_attributes: artist_info_attrs}
          expect(flash[:notice]).to eql "Your profile has been updated"
        end
        it "updates user address" do
          put :update, id: artist, commit: 'submit', artist: {studio_id: nil, artist_info_attributes: artist_info_attrs}
          expect(artist.address).to include street
        end
        it 'publishes an update message' do
          Messager.any_instance.should_receive(:publish)
          put :update, id: artist, commit: 'submit', artist: { artist_info_attributes: {street: 'wherever' }}
        end
      end
      context "update os status" do
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
      context 'update name and bio' do
        before do
          artist.update_os_participation OpenStudiosEvent.current, true
        end
        it 'does not reset the open studios participation setting' do
          expect{
            attrs = {"firstname"=>"mr joe", "artist_info_attributes"=>{"bio"=>"Dolor error praesentium et"}}
            put :update, id: artist, commit: 'submit', artist: attrs
          }.to_not change(artist, :doing_open_studios?)
        end
      end
    end
  end

  describe "#edit" do
    context "while not logged in" do
      before do
        get :edit, id: 'blahdeblah'
      end
      it_should_behave_like "redirects to login"
    end
    context 'while logged in as a fan' do
      before do
        login_as fan
        get :edit, id: fan.to_param
      end
      it { should redirect_to edit_user_path(fan) }
    end
    context "while logged in as someone with no address" do
      render_views
      before do
        login_as without_address
        get :edit, id: without_address.to_param
      end

      it { expect(response).to be_success }
      it "has the edit form" do
        assert_select("form.formtastic.artist");
      end
      it 'includes the open studios edit section' do
        assert_select("form.formtastic.artist .panel-collapse#events");
        assert_select '#events', /You need to specify an address or studio/
      end
    end

    context "while logged in" do
      render_views
      before do
        artist.artist_info.update_attributes({facebook: 'example.com/facebooklink', blog: 'example.com/bloglink'})
        login_as artist
        get :edit, id: artist.to_param
      end
      it { expect(response).to be_success }
      it 'has a hidden form for donation under the open studios section' do
        assert_select '#paypal_donate_openstudios'
      end
    end
  end

  describe "#show" do
    it 'when looking for a suspended artist' do
      artist.update_attribute('state', 'suspended')
      get :show, id: artist.id
      expect(flash[:error]).to be_present
      expect(response).to redirect_to artists_path
    end

    context "while not logged in" do
      render_views
      before(:each) do
        get :show, id: artist_with_tags.id
      end
      it { expect(response).to be_success }
      it 'has the artist\'s bio as the description' do
        assert_select 'head meta[name=description]' do |desc|
          desc.length.should eql 1
          c = desc.first.attributes['content']
          expect(c).to match artist_with_tags.bio[0..50]
          expect(c).to match /^Mission Artists United Artist/
          expect(c).to include html_encode(artist_with_tags.get_name, :named)
        end
        assert_select 'head meta[property=og:description]' do |desc|
          desc.length.should eql 1
          c = desc.first.attributes['content']
          expect(c).to include artist_with_tags.bio[0..50]
          expect(c).to match /^Mission Artists United Artist/
          expect(c).to include html_encode(artist_with_tags.get_name, :named)
        end
      end
      it 'has the artist\'s (truncated) bio as the description' do
        long_bio = Faker::Lorem.paragraphs(15).join
        artist_info.update_attribute(:bio, long_bio)
        get :show, id: artist.id
        assert_select 'head meta[name=description]' do |desc|
          desc.length.should eql 1
          c = desc.first.attributes['content']
          expect(c).to_not eql artist.bio
          expect(c).to include artist.bio.to_s[0..420]
          expect(c).to match /\.\.\.$/
          expect(c).to match /^Mission Artists United Artist/
          expect(c).to include html_encode(artist.get_name, :named)
        end
      end

      it 'displays links to the media' do
        media = artist_with_tags.art_pieces.compact.uniq.map{|ap| ap.medium.try(:name) }

        # fixture validation
        media.should have_at_least(1).medium

        Medium.where(name: media).each do |med|
          assert_select "a[href=#{medium_path(med)}]", med.name
        end

      end

      it 'has the artist tags and media as the keywords' do
        tags = artist_with_tags.art_pieces.map(&:tags).flatten.compact.uniq.map(&:name)
        media = artist_with_tags.art_pieces.map{|ap| ap.medium.try(:name) }
        expected = tags + media
        assert expected.length > 0, 'Fixture for artist needs some tags or media associations'
        assert_select 'head meta[name=keywords]' do |content|
          content.length.should eql 1
          actual = content[0].attributes['content'].split(',').map(&:strip)
          expected.each do |ex|
            expect(actual).to include ex
          end
        end
      end
      it 'has the default keywords' do
        assert_select 'head meta[name=keywords]' do |kws|
          kws.length.should eql 1
          expected = ["art is the mission", "art", "artists", "san francisco"]
          actual = kws[0].attributes['content'].split(',').map(&:strip)
          expected.each do |ex|
            expect(actual).to include ex
          end
        end
      end
    end

    it "reports cannot find artist" do
      get :show, id: fan.id
      expect(response).to redirect_to artists_path
    end

    context "while logged in" do
      before do
        login_as(artist)
      end

      context "after a user favorites the logged in artist and show the artists page" do
        render_views
        before do
          artist2.add_favorite(artist)
          get :show, id: artist.id
        end
        it { expect(response).to be_success }
        it "has the user linked in the 'who favorites me' section" do
          assert_select ".favorite-thumbs a[href^=/users/#{artist2.slug}] .artist__favorite-thumb"
        end
      end
    end

    context "after an artist favorites another artist and show the artists page" do
      render_views
      before do
        artist.add_favorite(artist2)
        login_as(artist)
        get :show, id: artist.id
      end
      it { expect(response).to be_success }
      it "shows favorites on show page with links" do
        assert_select("a[href=#{favorites_path(artist)}]");
      end
    end

    context "while not logged in" do
      render_views
      before(:each) do
        artist.artist_info.update_attribute(:facebook, "http://www.facebook.com/#{artist.login}")
        get :show, id: artist.id
      end
      it_should_behave_like "not logged in"
      it "website is present" do
        assert_select(".link a[href=#{artist.url}]")
      end
      it "has no sidebar nav " do
        expect(css_select('#sidebar_nav')).to be_empty
      end
      it "facebook is present and correct" do
        assert_select(".link a[href=#{artist_info.facebook}]")
      end
    end
    describe 'logged in as admin' do
      before do
        login_as admin
        get :show, id: artist.id
      end
      it { expect(response).to be_success }
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
          expect(response).to redirect_to artist_url(artist)
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

      it "sets a flash and redirects to the artist page with invalid params" do
        post :setarrangement
        expect(response).to redirect_to(artist_path(artist))
        flash[:error].should be_present
      end

      it 'does not rearrange art if cancel is pressed' do
        order1 = artist.art_pieces.map(&:id)
        post :setarrangement, {  neworder: [order1.last] + order1[0..-2], submit: 'cancel' }
        expect(artist.art_pieces.map(&:id)).to eql order1
      end
      it 'redirects to the artists page' do
        order1 = [ @artpieces[0], @artpieces[2], @artpieces[1] ]
        post :setarrangement, { neworder: order1.join(",") }
        expect(response).to redirect_to artist_path(artist)
      end
      it 'does not redirect if request is xhr' do
        order1 = [ @artpieces[0], @artpieces[2], @artpieces[1] ]
        xhr :post, :setarrangement, { neworder: order1.join(",") }
        expect(response).to be_success
      end
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

  describe '#manage_art' do
    before do
      login_as artist
    end
    it 'assigns a new art piece' do
      get :manage_art, artist_id: artist.id
      assigns(:art_piece).should be_a_kind_of ArtPiece
    end
  end


  describe '#suggest' do
    before do
      Rails.cache.clear
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

end
