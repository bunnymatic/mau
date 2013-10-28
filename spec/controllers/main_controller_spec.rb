require 'spec_helper'

include AuthenticatedTestHelper

shared_examples_for "successful notes mailer response" do
  it_should_behave_like "returns success"
  it "response should return status success" do
    @resp['status'].should eql 'success'
  end
  it "response should not have messages" do
    @resp['messages'].length.should eql 0
  end
end

shared_examples_for 'has some invalid params' do
  it "responds with error status" do
    @resp['status'].should eql 'error'
  end
  it "response does not report 'invalid note type'" do
    @resp['messages'].should_not include 'invalid note type'
  end
  it "response reports 'not enough parameters'" do
    @resp['messages'].should include 'not enough parameters'
  end
end

shared_examples_for 'main#index page' do
  it_should_behave_like 'standard sidebar layout'
  it 'has social icons in the main text section' do
    assert_select '.main-text .social'
  end
  it 'does not have social icons in the sidebar' do
    (css_select '.lcol .social').should be_empty
  end
  it "shows search box" do
    assert_select '#search_box'
  end
  it "shows thumbnails" do
    assert_select "#main_thumbs #sampler"
  end
  it "has a feed container" do
    assert_select "#feed_div"
  end
  it 'shows a link to the artist with the most recently uploaded art' do
    assert_select '.lcol .new_art a[href=%s]' % artist_path(ArtPiece.last.artist)
  end
  it "has a header menu" do
    assert_select '#header_bar'
    assert_select '#artisthemission'
  end
  it "has a footer menu" do
    assert_select '#footer_bar'
    assert_select '#footer_copy'
    assert_select '#footer_links'
  end
  it 'has the default description' do
    assert_select 'head meta[name=description]' do |desc|
      desc.length.should eql 1
      desc[0].attributes['content'].should eql "Mission Artists United is a website dedicated to the unification of artists in the Mission District of San Francisco.  We promote the artists and the community. Art is the Mission!"
    end
    assert_select 'head meta[property=og:description]' do |desc|
      desc.length.should eql 1
      desc[0].attributes['content'].should eql "Mission Artists United is a website dedicated to the unification of artists in the Mission District of San Francisco.  We promote the artists and the community. Art is the Mission!"
    end
  end
  it 'has the default keywords' do
    assert_select 'head meta[name=keywords]' do |keywords|
      keywords.length.should eql 1
      expected = ["art is the mission", "art", "artists", "san francisco"]
      actual = keywords[0].attributes['content'].split(',').map(&:strip)
      expected.each do |ex|
        actual.should include ex
      end
    end
  end
end

describe MainController do

  fixtures :users, :roles, :roles_users, :studios, :artist_infos, :cms_documents,  :emails, :email_lists, :email_list_memberships, :art_pieces

  describe "#index" do
    render_views
    context 'not logged in' do
      before do
        get :index
      end
      it_should_behave_like 'main#index page'
    end
    describe 'logged in' do
      before do
        login_as(:admin)
        get :index
      end
      it_should_behave_like 'main#index page'
      it_should_behave_like 'logged in as admin'
    end

    describe 'format=json' do
      before do
        FactoryGirl.create_list(:art_piece, 15, :artist => users(:joeblogs))
        get :index, :format => "json"
      end
      it_should_behave_like 'successful json'
      it 'returns up to 15 random images' do
        j = JSON.parse(response.body)
        j.should have(15).images
      end
    end
  end

  describe "#news" do
    render_views
    context "while not logged in" do
      before do
        get :resources
      end
      it_should_behave_like "not logged in"
      it_should_behave_like 'standard sidebar layout'
      it 'has social icons in the sidebar' do
        assert_select '.lcol .social'
      end

    end
    context "while logged in as an art fan" do
      before do
        u = users(:maufan1)
        login_as(users(:maufan1))
        @logged_in_user = u
        get :resources
      end
      it_should_behave_like "logged in user"
    end
    context "while logged in as artist" do
      before do
        a = users(:artist1)
        login_as(users(:artist1))
        @logged_in_user = a
        @logged_in_artist = a
        get :resources
      end
      it_should_behave_like "logged in user"
      it_should_behave_like "logged in artist"
    end
    context "while logged in as user with 'editor' role" do
      before do
        u = users(:editor)
        login_as(:editor)
        @logged_in_user = u
        get :resources
      end
      it_should_behave_like "logged in as editor"
    end
    context 'logged in as admin' do
      before do
        login_as(:admin)
        get :resources
      end
      it_should_behave_like 'returns success'
      it_should_behave_like 'logged in as admin'
    end
  end
  describe "#about" do
    render_views
    context "while not logged in" do
      before do
        get :about
      end
      it_should_behave_like "not logged in"
      it 'fetches markdown content' do
        assigns(:content).should have_key :content
        assigns(:content).should have_key :cmsid
      end
    end

    context "while logged in as an art fan" do
      before do
        u = users(:maufan1)
        login_as(users(:maufan1))
        @logged_in_user = u
        get :about
      end
      it_should_behave_like "logged in user"
    end
    context "while logged in as artist" do
      before do
        a = users(:artist1)
        login_as(users(:artist1))
        @logged_in_user = a
        get :about
      end
      it_should_behave_like "logged in user"
    end
  end
  describe "#history" do
    render_views
    context "while not logged in" do
      before do
        get :history
      end
      it_should_behave_like "not logged in"
      it 'fetches markdown content' do
        assigns(:content).should have_key :content
        assigns(:content).should have_key :cmsid
      end
    end

    context "while logged in as an art fan" do
      before do
        u = users(:maufan1)
        login_as(users(:maufan1))
        @logged_in_user = u
        get :history
      end
      it_should_behave_like "logged in user"
    end
    context "while logged in as artist" do
      before do
        a = users(:artist1)
        login_as(users(:artist1))
        @logged_in_user = a
        get :history
      end
      it_should_behave_like "logged in user"
    end
  end
  describe "#getinvolved" do
    render_views
    context "while not logged in" do
      before do
        get :getinvolved
      end
      it_should_behave_like "not logged in"
    end
    context "while logged in as an art fan" do
      before do
        u = users(:maufan1)
        login_as(users(:maufan1))
        @logged_in_user = u
        get :getinvolved
      end
      it_should_behave_like "logged in user"
    end
    context "while logged in as artist" do
      before do
        a = users(:artist1)
        login_as(users(:artist1))
        @logged_in_user = a
        get :getinvolved
      end
      it_should_behave_like "logged in user"
    end
    describe '/paypal_success' do
      before do
        post :getinvolved, :p => 'paypal_success'
      end
      it_should_behave_like 'returns success'
      it 'sets some info about the page' do
        (/Get Involved/ =~ assigns(:page_title)).should be
      end
      it 'assigns the proper paypal page' do
        assigns(:page).should eql 'paypal_success'
      end
    end
    describe 'send feedback' do
      context 'with no email' do
        before do
          get :getinvolved, :commit => true, :feedback => FactoryGirl.attributes_for(:feedback, :email => nil)
        end
        it 'renders a flash' do
          flash[:error].should match /email was blank/
        end
      end
      context 'with no comment' do
        before do
          get :getinvolved, :commit => true, :feedback => FactoryGirl.attributes_for(:feedback, :comment => nil)
        end
        it 'renders a flash' do
          flash[:error].should match /fill something in/
        end
      end
      context 'with data' do
        before do
          FeedbackMailer.stub(:feedback => double("FeedbackMailer", :deliver! => true))
        end
        it 'saves a feedback record' do
          expect {
            get :getinvolved, :commit => true, :feedback => FactoryGirl.attributes_for(:feedback)
          }.to change(Feedback, :count).by(1)
        end
        it 'sets the flash notice' do
          get :getinvolved, :commit => true, :feedback => FactoryGirl.attributes_for(:feedback)
          flash.now[:notice].should be_present
        end
        it 'sends an email' do
          FeedbackMailer.should_receive(:feedback).and_return(double("deliverable", :deliver! => true))
          get :getinvolved, :commit => true, :feedback => FactoryGirl.attributes_for(:feedback)
        end
      end
    end
  end

  describe "#privacy" do
    render_views
    context "while not logged in" do
      before do
        get :privacy
      end
      it_should_behave_like "not logged in"
    end
    context "while logged in as an art fan" do
      before do
        u = users(:maufan1)
        login_as(users(:maufan1))
        @logged_in_user = u
        get :privacy
      end
      it_should_behave_like "logged in user"
    end
    context "while logged in as artist" do
      before do
        a = users(:artist1)
        login_as(users(:artist1))
        @logged_in_user = a
        get :privacy
      end
      it_should_behave_like "logged in user"
    end
  end
  describe "#about" do
    render_views
    context "while not logged in" do
      before do
        get :about
      end
      it_should_behave_like "not logged in"
    end
    context "while logged in as an art fan" do
      before do
        u = users(:maufan1)
        login_as(users(:maufan1))
        @logged_in_user = u
        get :about
      end
      it_should_behave_like "logged in user"
    end
    context "while logged in as artist" do
      before do
        a = users(:artist1)
        login_as(users(:artist1))
        @logged_in_user = a
        get :about
      end
      it_should_behave_like "logged in user"
    end
  end
  describe "#faq" do
    render_views
    context "while not logged in" do
      before do
        get :faq
      end
      it_should_behave_like "not logged in"
    end
    context "while logged in as an art fan" do
      before do
        u = users(:maufan1)
        login_as(users(:maufan1))
        @logged_in_user = u
        get :faq
      end
      it_should_behave_like 'standard sidebar layout'
      it_should_behave_like "logged in user"
      it 'has social icons in the sidebar' do
        assert_select '.lcol .social'
      end
    end
    context "while logged in as artist" do
      before do
        a = users(:artist1)
        login_as(users(:artist1))
        @logged_in_user = a
        get :faq
      end
      it_should_behave_like 'standard sidebar layout'
      it_should_behave_like "logged in user"
      it 'has social icons in the sidebar' do
        assert_select '.lcol .social'
      end

    end
  end
  describe '#main/venues' do
    render_views
    context "while not logged in" do
      before do
        get :venues
      end
      it_should_behave_like 'standard sidebar layout'
      it_should_behave_like "not logged in"
      it 'has social icons in the sidebar' do
        assert_select '.lcol .social'
      end

    end
    context 'logged in as admin' do
      before do
        login_as(:admin)
        get :venues
      end
      it_should_behave_like 'logged in as admin'
      it "renders the markdown version" do
        assert_select '.markdown h1', :match => 'these'
        assert_select '.markdown h2', :match => 'are'
        assert_select '.markdown h3', :match => 'venues'
        assert_select '.markdown ul li', :count => 3
      end
      it 'the markdown entry have cms document ids in them' do
        cmsdoc = cms_documents(:venues)
        assert_select '.markdown.editable[data-cmsid=%s]' % cmsdoc.id
      end
    end
  end

  describe "#main/openstudios" do
    render_views
    context "while not logged in" do
      before do
        get :openstudios
      end
      it_should_behave_like 'standard sidebar layout'
      it_should_behave_like "not logged in"
      it 'has social icons in the sidebar' do
        assert_select '.lcol .social'
      end

      it 'assigns participating studios with only studios that have os artists without studio = 0' do
        n = Artist.active.open_studios_participants.select{|a| !a.studio_id.nil? && a.studio_id != 0}.map(&:studio).uniq.count
        assigns(:participating_studios).should have(n).studios
      end
      it 'contains participant count for studios should be > 0' do
        assigns(:participating_studios).each do |s|
          s.artists.open_studios_participants.length.should > 0
        end
      end
      it "participating studios should be in alpha order by name (ignoring 'the')" do
        assigns(:participating_studios).sort{|a,b| a.name.downcase.gsub(/^the\ /, '') <=> b.name.downcase.gsub(/^the\ /,'')}.map(&:name).should eql assigns(:participating_studios).map(&:name)
      end
      it 'assigns the right number of participating indies (all os participants with studio = 0)' do
        n = Artist.active.open_studios_participants.map(&:studio_id).select{|sid| sid==0}.count
        n.should > 0
        assigns(:participating_indies).should have(n).artists
      end
      it 'participating artists are in alpha order by last name' do
        assigns(:participating_indies).sort{|a,b| a.lastname.downcase <=> b.lastname.downcase}.should eql assigns(:participating_indies)
      end
      it "renders the markdown version" do
        assert_select '.markdown h1', :match => 'pr header'
        assert_select '.markdown h2', :match => 'pr header2'
        assert_select '.markdown p em', :match => 'preview'
      end
      it 'fetches the markdown content properly' do
        assigns(:summary).should have_key :content
        assigns(:summary).should have_key :cmsid
        assigns(:preview_reception_html).should have_key :content
        assigns(:preview_reception_html).should have_key :cmsid
      end
      it 'the markdown entries have cms document ids in them' do
        [ CmsDocument.where(:section => 'summary').all,
          CmsDocument.where(:section => 'preview_reception').all ].flatten.each do |cmsdoc|
          assert_select '.markdown.editable[data-cmsid=%s]' % cmsdoc.id
        end
      end
      it "uses cms for parties" do
        CmsDocument.should_receive(:where).at_least(2).and_return([:os_blurb,:os_preview_reception].map{|k| cms_documents(k)})

        get :openstudios
      end
      context "while logged in as an art fan" do
        before do
          u = users(:maufan1)
          login_as(users(:maufan1))
          @logged_in_user = u
          get :openstudios
        end
        it_should_behave_like "logged in user"
      end
      context "while logged in as artist" do
        before do
          a = users(:artist1)
          login_as(users(:artist1))
          @logged_in_user = a
          get :openstudios
        end
        it_should_behave_like "logged in user"
      end
    end
  end

  describe 'non_mobile' do
    it 'sets the session cookie to force non mobile' do
      get :non_mobile
      session[:mobile_view].should be_false
    end
    it 'redirects to root (if no referrer)' do
      request.env["HTTP_REFERER"] = nil
      get :non_mobile
      response.should redirect_to root_path
    end
    it 'redirects to root if referrer is not in our domain' do
      request.env["HTTP_REFERER"] = 'http://gmail.com/mail'
      get :non_mobile
      response.should redirect_to root_path
    end
    it 'redirects to referrer if there is one' do
      get :non_mobile
      response.should redirect_to SHARED_REFERER
    end
    it 'redirects to referrer if there is one with full domain' do
      request.env["HTTP_REFERER"] = 'http://test.host' + SHARED_REFERER
      get :mobile
      response.should redirect_to SHARED_REFERER
    end
  end

  describe 'mobile' do
    it 'sets the session cookie to force non mobile' do
      get :mobile
      session[:mobile_view].should be_true
    end
    it 'redirects to root (if no referrer)' do
      request.env["HTTP_REFERER"] = nil
      get :mobile
      response.should redirect_to root_path
    end
    it 'redirects to root if referrer is not in our domain' do
      request.env["HTTP_REFERER"] = 'http://gmail.com/mail'
      get :mobile
      response.should redirect_to root_path
    end
    it 'redirects to referrer if there is one' do
      get :mobile
      response.should redirect_to SHARED_REFERER
    end
    it 'redirects to referrer if there is one' do
      request.env["HTTP_REFERER"] = 'http://test.host' + SHARED_REFERER
      get :mobile
      response.should redirect_to SHARED_REFERER
    end
  end

  describe 'letter_from_howard_flax' do
    render_views
    before do
      get :letter_from_howard_flax
    end
    it_should_behave_like 'returns success'
    it 'has the title' do
      assert_select('h4', 'Letter from Howard Flax');
    end
  end

  describe 'notes mailer' do
    before do
      FeedbackMailer.any_instance.stub(:deliver! => true)
    end
    context "invalid calls" do
      ['get', 'post', 'put', 'delete'].each do |rtype|
        desc = "returns error if request type is %s" % rtype
        it desc do
          eval rtype + " :notes_mailer"
          response.should be_missing
        end
      end
    end
    describe "xhr post" do
      before do
        xhr :post, :notes_mailer
        @j = JSON::parse(response.body)
      end
      it_should_behave_like 'successful json'
      it "response has error status" do
        @j['status'].should eql 'error'
      end
      it "response reports 'invalid note type'" do
        @j['messages'].should include 'invalid note type'
      end
      it "response only has one error message" do
        @j['messages'].size.should eql 1
      end
    end

    describe "submission given invalid note_type" do
      before do

        xhr :post, :notes_mailer, :note_type => 'bogus', :email => 'a@b.com'
        @resp = JSON::parse(response.body)
      end
      it "response has error status" do
        @resp['status'].should eql 'error'
      end
      it "response reports 'invalid note type'" do
        @resp['messages'].should include 'invalid note type'
      end
    end

    describe "submission given note_type email_list and email only" do
      before do
        xhr :post, :notes_mailer, :note_type => 'email_list', :email => 'a@b.com'
        @resp = JSON::parse(response.body)
      end
      it_should_behave_like "has some invalid params"
      it "response reports 'Email confirm cant be blank'" do
        @resp['messages'].should include "Email confirm can't be blank"
      end
      it "response reports 'emails do not match'" do
        @resp['messages'].should include 'emails do not match'
      end
    end

    describe "submission given note_type feedlink with email only" do
      before do
        xhr :post, :notes_mailer, :note_type => 'feed_submission', :email => 'a@b.com'
        @resp = JSON::parse(response.body)
      end
      it_should_behave_like "has some invalid params"
      it "response reports 'feed url cannot be empty'" do
        @resp['messages'].should include 'feed url can\'t be empty'
      end
    end

    describe "submission given note_type inquiry and email only" do
      before do
        xhr :post, :notes_mailer, :note_type => 'inquiry', :email => 'a@b.com'
        @resp = JSON::parse(response.body)
      end
      it_should_behave_like "has some invalid params"
      it "response reports 'Email confirm cant be blank'" do
        @resp['messages'].should include "Email confirm can't be blank"
      end
      it "response reports 'emails do not match'" do
        @resp['messages'].should include 'emails do not match'
      end
      it "response reports 'note cannot be empty'" do
        @resp['messages'].should include 'note cannot be empty'
      end
    end

    describe "submission given note_type inquiry, both emails but no inquiry" do
      before do
        xhr :post, :notes_mailer, :note_type => 'inquiry',
          :email => 'a@b.com', :email_confirm => 'a@b.com'
        @resp = JSON::parse(response.body)
      end
      it_should_behave_like "has some invalid params"
      it "has only 1 message" do
        @resp['messages'].size == 1
      end
      it "message is note cannot be empty" do
        @resp['messages'].should include 'note cannot be empty'
      end
    end

    describe "submission with valid params" do
      context "email_list" do
        before do
          xhr :post, :notes_mailer, :note_type => 'email_list',
            :email => 'a@b.com', :email_confirm => 'a@b.com'
          @resp = JSON::parse(response.body)
        end
        it_should_behave_like "successful notes mailer response"
        it 'triggers FeedbackMailer.feedback' do
          FeedbackMailer.should_receive(:feedback).with() do |f|
            f.login.should eql 'anon'
            f.comment.should include 'a@b.com'
            f.subject.should eql 'MAU Submit Form : email_list'
            f.email.should eql 'a@b.com'
          end.and_return(double(:deliver! => true))
          xhr :post, :notes_mailer, :note_type => 'email_list',
            :email => 'a@b.com', :email_confirm => 'a@b.com'
        end
        it 'adds a feedback item to the db' do
          expect {
            xhr :post, :notes_mailer, :note_type => 'email_list',
                 :email => 'a@b.com', :email_confirm => 'a@b.com'
          }.to change(Feedback, :count).by(1)
        end
      end
      context "inquiry" do
        before do
          xhr :post, :notes_mailer, :note_type => 'inquiry',
            :inquiry => 'cool note',
            :email => 'a@b.com', :email_confirm => 'a@b.com'
          @resp = JSON::parse(response.body)
        end
        it_should_behave_like 'successful notes mailer response'
      end

      context "help" do
        before do
          xhr :post, :notes_mailer, :note_type => 'help',
            :inquiry => 'cool note',
            :email => 'a@b.com', :email_confirm => 'a@b.com'
          @resp = JSON::parse(response.body)
        end
        it_should_behave_like 'successful notes mailer response'
      end
      context "feeds link" do
        before do
          xhr :post, :notes_mailer, :note_type => 'feed_submission',
            :feedlink => 'http://feed/feed.rss'
          @resp = JSON::parse(response.body)
        end
        it_should_behave_like 'successful notes mailer response'

        it 'triggers FeedbackMailer.deliver_feedback' do
          FeedbackMailer.should_receive(:feedback).with() do |f|
            f.login.should eql 'anon'
            f.comment.should include 'feed.rss'
            f.subject.should eql 'MAU Submit Form : feed_submission'
          end.and_return(double(:deliver! => true))

          xhr :post, :notes_mailer, :note_type => 'feed_submission',
            :feedlink => 'http://feed/feed.rss'
        end
      end
    end
  end

  describe 'status' do
    render_views
    it 'hits the database' do
      Medium.should_receive :first
      get :status_page
    end
    it 'returns success' do
      get :status_page
      response.should be_success
    end
  end
  describe 'get_random_pieces' do
    it 'returns art pieces' do
      pieces = @controller.get_random_pieces
      pieces.map(&:class).uniq.should eql [ArtPiece]
    end
  end

  describe 'version' do
    it 'returns the app version' do
      get :version
      response.body.should eql 'Dart 5.0 [unk]'
    end
  end

  describe 'sampler' do
    before do
      get :sampler
    end
    it 'grabs some random pieces' do
      assigns(:rand_pieces).should have_at_least(1).piece
      assigns(:rand_pieces).map(&:class).uniq.should eql [ArtPiece]
    end

    it 'renders the thumbs partial' do
      response.should render_template 'thumbs'
    end
  end
end
