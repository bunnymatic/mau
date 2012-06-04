require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

include AuthenticatedTestHelper

shared_examples_for "successful notes mailer response" do
  it_should_behave_like "returns success"
  it "response should return status success" do
    @resp['status'].should == 'success'
  end
  it "response should not have messages" do
    @resp['messages'].length.should == 0
  end
end

shared_examples_for 'has some invalid params' do
  it "responds with error status" do
    @resp['status'].should == 'error'
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
      desc.length.should == 1
      desc[0].attributes['content'].should == "Mission Artists United is a website dedicated to the unification of artists in the Mission District of San Francisco.  We promote the artists and the community. Art is the Mission!"
    end
    assert_select 'head meta[property=og:description]' do |desc|
      desc.length.should == 1
      desc[0].attributes['content'].should == "Mission Artists United is a website dedicated to the unification of artists in the Mission District of San Francisco.  We promote the artists and the community. Art is the Mission!"
    end
  end
  it 'has the default keywords' do
    assert_select 'head meta[name=keywords]' do |keywords|
      keywords.length.should == 1
      expected = ["art is the mission", "art", "artists", "san francisco"]
      actual = keywords[0].attributes['content'].split(',').map(&:strip)
      expected.each do |ex|
        actual.should include ex
      end
    end
  end
end

describe MainController do

  fixtures :users, :studios, :artist_infos, :cms_documents, :roles, :emails, :email_lists, :email_list_memberships, :art_pieces

  describe "#index" do
    integrate_views
    context 'not logged in' do
      before do
        get :index
      end
      it_should_behave_like 'main#index page'
      it 'does show the action button for call for entries if the date is before March 11 2011 (the deadline)' do
        t = Time.utc(2012, 3, 10)
        Time.stubs(:now).returns(t)
        get :index
        assert_select '.sprite.call_for_entries.action_button'
        assert_select 'a[href=/wizards/mau042012]'
        assert_select '.action_button', :count => 4
      end
      it 'doesn\'t show the action button for call for entries if the date is after March 14 2011 (the deadline)' do
        t = Time.utc(2012, 3, 14)
        Time.stubs(:now).returns(t)
        get :index
        response.should_not have_tag '.sprite.call_for_entries.action_button'
        response.should_not have_tag 'a[href=/wizards/mau042012]'
        assert_select '.action_button', :count => 3
      end
    end
    describe 'logged in' do
      before do
        login_as(:admin)
        get :index
      end
      it_should_behave_like 'main#index page'
      it_should_behave_like 'logged in as admin'
    end
    
  end

  describe "- route generation" do
    it 'has named openstudios route which points to main/openstudios' do
      openstudios_path.should match /^\/openstudios/
    end
  end
  describe "- route recognition" do
    it "calls main controller openstudios method for '/openstudios'" do
      params_from(:get, "/openstudios").should == {:controller => 'main', :action => 'openstudios' }
    end
    it "should generate {:controller=>main, action=>venues} from ANY 'venues'" do
      methods = [:get, :put, :delete, :post]
      methods.each do |m|
        params_from(m, "/venues").should == {:controller => 'main', :action => 'venues' }
      end
    end
    it "should generate {:controller=>main, action=>faq} from ANY 'faq'" do
      methods = [:get, :put, :delete, :post]
      methods.each do |m|
        params_from(m, "/faq").should == {:controller => 'main', :action => 'faq' }
      end
    end

    it "should generate {:controller=>main, action=>getinvolved} from ANY 'getinvolved'" do
      methods = [:get, :put, :delete, :post]
      methods.each do |m|
        params_from(m, "/getinvolved").should == {:controller => 'main', :action => 'getinvolved' }
      end
    end
    it "should generate {:controller=>main, action=>about} from ANY 'about'" do
      methods = [:get, :put, :delete, :post]
      methods.each do |m|
        params_from(m, "/about").should == {:controller => 'main', :action => 'about' }
      end
    end
    it "should generate {:controller=>main, action=>privacy} from ANY 'privacy'" do
      methods = [:get, :put, :delete, :post]
      methods.each do |m|
        params_from(m, "/privacy").should == {:controller => 'main', :action => 'privacy' }
      end
    end
    it "should generate {:controller=>main, action=>contact} from ANY 'contact'" do
      methods = [:get, :put, :delete, :post]
      methods.each do |m|
        params_from(m, "/contact").should == {:controller => 'main', :action => 'contact' }
      end
    end
    it "should generate {:controller=>main, action=>resources} from ANY 'news'" do
      methods = [:get, :put, :delete, :post]
      methods.each do |m|
        params_from(m, "/news").should == {:controller => 'main', :action => 'resources' }
      end
    end
    it "should generate {:controller=>main, action=>resources} from ANY 'resources'" do
      methods = [:get, :put, :delete, :post]
      methods.each do |m|
        params_from(m, "/resources").should == {:controller => 'main', :action => 'resources' }
      end
    end
  end

  describe "#news" do
    integrate_views
    context "while not logged in" do
      before do
        get :resources
      end
      it_should_behave_like "not logged in"
      it_should_behave_like 'standard sidebar layout'
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
    integrate_views
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
    integrate_views
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
    integrate_views
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
        assigns(:page).should == 'paypal_success'
      end
    end
  end
  describe "#privacy" do
    integrate_views
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
    integrate_views
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
    integrate_views
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
    end
  end
  describe '#main/venues' do
    integrate_views
    context "while not logged in" do
      before do
        get :venues
      end
      it_should_behave_like 'standard sidebar layout'
      it_should_behave_like "not logged in"
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
    integrate_views
    context "while not logged in" do
      before do
        get :openstudios
      end
      it_should_behave_like 'standard sidebar layout'
      it_should_behave_like "not logged in"
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
        assigns(:participating_studios).sort{|a,b| a.name.downcase.gsub(/^the\ /, '') <=> b.name.downcase.gsub(/^the\ /,'')}.map(&:name).should == assigns(:participating_studios).map(&:name)
      end
      it 'assigns the right number of participating indies (all os participants with studio = 0)' do
        n = Artist.active.open_studios_participants.map(&:studio_id).select{|sid| sid==0}.count
        n.should > 0
        assigns(:participating_indies).should have(n).artists
      end
      it 'participating artists are in alpha order by last name' do
        assigns(:participating_indies).sort{|a,b| a.lastname.downcase <=> b.lastname.downcase}.should == assigns(:participating_indies)
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
        [ CmsDocument.find_by_section('summary'),
          CmsDocument.find_by_section('preview_reception') ].each do |cmsdoc|
          assert_select '.markdown.editable[data-cmsid=%s]' % cmsdoc.id
        end
      end
      it "uses cms for parties" do
        CmsDocument.expects(:find_by_page_and_section).at_least(2)
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

  describe 'letter_from_howard_flax' do
    integrate_views
    before do
      get :letter_from_howard_flax
    end
    it_should_behave_like 'returns success'
    it 'has the title' do
      assert_select('h4', 'Letter from Howard Flax');
    end
  end

  describe 'notes mailer' do
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
      it_should_behave_like 'returns success'
      it "returns json" do
        response.content_type.should == 'application/json'
      end
      it "response has error status" do
        @j['status'].should == 'error'
      end
      it "response reports 'invalid note type'" do
        @j['messages'].should include 'invalid note type'
      end
      it "response only has one error message" do
        @j['messages'].size.should == 1
      end
    end

    describe "submission given invalid note_type" do
      before do
        xhr :post, :notes_mailer, :note_type => 'bogus', :email => 'a@b.com'
        @resp = JSON::parse(response.body)
      end
      it "response has error status" do
        @resp['status'].should == 'error'
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
        it 'triggers FeedbackMailer.deliver_feedback' do
          FeedbackMailer.expects(:deliver_feedback).with() do |f|
            f.login.should == 'anon'
            f.comment.should include 'a@b.com'
            f.subject.should == 'MAU Submit Form : email_list'
            f.email.should == 'a@b.com'
          end
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
          FeedbackMailer.expects(:deliver_feedback).with() do |f|
            f.login.should == 'anon'
            f.comment.should include 'feed.rss'
            f.subject.should == 'MAU Submit Form : feed_submission'
          end
          xhr :post, :notes_mailer, :note_type => 'feed_submission', 
            :feedlink => 'http://feed/feed.rss'
        end
      end
    end
  end
end

