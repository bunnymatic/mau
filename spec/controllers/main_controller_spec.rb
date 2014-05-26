require 'spec_helper'

shared_examples_for "successful notes mailer response" do
  it_should_behave_like "returns success"
  it{JSON.parse(response.body)['errors'].should be_empty}
end

shared_examples_for 'has some invalid params' do
  it{expect(response).to be_4xx}
  it{JSON.parse(response.body)['errors'].should be_present}
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
      desc[0].attributes['content'].should match /^Mission Artists United is a website/
    end
    assert_select 'head meta[property=og:description]' do |desc|
      desc.length.should eql 1
      desc[0].attributes['content'].should match /^Mission Artists United is a website/
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

  fixtures :users, :roles, :roles_users, :studios, :artist_infos, :art_piece_tags, :art_pieces_tags, :media,
  :cms_documents,  :emails, :email_lists, :email_list_memberships, :art_pieces

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
      it 'includes the markdown content' do
        assert_select('.markdown')
      end
      it 'includes the art is the mission footer' do
        assert_select('.news-footer')
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
      it 'includes the markdown content' do
        assert_select('.markdown')
      end
      it 'includes the art is the mission footer' do
        assert_select('.news-footer')
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
    describe '/paypal_cancel' do
      before do
        post :getinvolved, :p => 'paypal_cancel'
      end
      it_should_behave_like 'returns success'
      it 'sets some info about the page' do
        (/Get Involved/ =~ assigns(:page_title)).should be
      end
      it 'assigns the proper paypal page' do
        assigns(:page).should eql 'paypal_cancel'
      end
    end
    describe 'send feedback' do
      let(:email) { 'joe@wherever.com' }
      let(:comment) { 'here we are' }
      let(:login) { FactoryGirl.build(:user).login }
      let(:feedback_attrs) { FactoryGirl.attributes_for(:feedback,
                                                        :login => login,
                                                        :email => email,
                                                        :comment => comment) }
      context 'with no comment' do
        let(:comment) { nil }
        before do
          get :getinvolved, :commit => true, :feedback => feedback_attrs
        end
        it 'renders a flash' do
          expect(assigns(:feedback).errors.full_messages).to include "Comment can't be blank"
        end
      end
      context 'with data' do
        before do
          FeedbackMailer.stub(:feedback => double("FeedbackMailer", :deliver! => true))
        end
        it 'saves a feedback record' do
          expect {
            get :getinvolved, :commit => true, :feedback => feedback_attrs
          }.to change(Feedback, :count).by(1)
        end
        it 'sets the flash notice' do
          get :getinvolved, :commit => true, :feedback => feedback_attrs
          flash.now[:notice].should be_present
        end
        it 'sends an email' do
          expect(FeedbackMailer).to receive(:feedback).and_return(double("deliverable", :deliver! => true))
          get :getinvolved, :commit => true, :feedback => feedback_attrs
        end
      end
      context 'when you\'re logged in' do
        before do
          login_as :artist1
          FeedbackMailer.stub(:feedback => double("FeedbackMailer", :deliver! => true))
        end
        it 'sends an email' do
          FeedbackMailer.should_receive(:feedback).and_return(double("deliverable", :deliver! => true))
          get :getinvolved, :commit => true, :feedback => feedback_attrs
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

  describe "#main/open_studios" do
    render_views
    context "while not logged in" do
      before do
        get :open_studios
      end
      it_should_behave_like 'standard sidebar layout'
      it_should_behave_like "not logged in"
      it 'has social icons in the sidebar' do
        assert_select '.lcol .social'
      end

      it "renders the markdown version" do
        assert_select '.markdown h1', :match => 'pr header'
        assert_select '.markdown h2', :match => 'pr header2'
        assert_select '.markdown p em', :match => 'preview'
      end

      it 'the markdown entries have cms document ids in them' do
        [ CmsDocument.where(:section => 'summary').all,
          CmsDocument.where(:section => 'preview_reception').all ].flatten.each do |cmsdoc|
          assert_select '.markdown[data-cmsid=%s]' % cmsdoc.id
        end
      end
      it "uses cms for parties" do
        docs = [:os_blurb,:os_preview_reception].map{|k| cms_documents(k)}
        expect(CmsDocument).to receive(:where).at_least(2).and_return(docs)
        get :open_studios
      end
    end
    context "while logged in as an art fan" do
      let(:fan) { users(:maufan1) }
      before do
        @logged_in_user = login_as fan
        get :open_studios
      end
      it_should_behave_like "logged in user"
    end
    context "while logged in as artist" do
      let(:artist) { users(:artist1) }
      before do
        @logged_in_user = login_as artist
        get :open_studios
      end
      it_should_behave_like "logged in user"
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
      expect(response).to redirect_to root_path
    end
    it 'redirects to root if referrer is not in our domain' do
      request.env["HTTP_REFERER"] = 'http://gmail.com/mail'
      get :non_mobile
      expect(response).to redirect_to root_path
    end
    it 'redirects to referrer if there is one' do
      get :non_mobile
      expect(response).to redirect_to SHARED_REFERER
    end
    it 'redirects to referrer if there is one with full domain' do
      request.env["HTTP_REFERER"] = 'http://test.host' + SHARED_REFERER
      get :mobile
      expect(response).to redirect_to SHARED_REFERER
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
      expect(response).to redirect_to root_path
    end
    it 'redirects to root if referrer is not in our domain' do
      request.env["HTTP_REFERER"] = 'http://gmail.com/mail'
      get :mobile
      expect(response).to redirect_to root_path
    end
    it 'redirects to referrer if there is one' do
      request.env["HTTP_REFERER"] = 'http://test.host' + SHARED_REFERER
      get :mobile
      expect(response).to redirect_to SHARED_REFERER
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
          send(rtype, :notes_mailer)
          expect(response).to be_missing
        end
      end
    end
    describe "xhr post" do
      before do
        xhr :post, :notes_mailer
        @j = JSON::parse(response.body)
      end
      it{expect(response).to be_4xx}
      it "response reports 'invalid note type'" do
        @j['errors'].keys.should include 'email'
        @j['errors'].keys.should include 'email_confirm'
        @j['errors'].keys.should include 'note_type'
      end
    end

    describe "submission given invalid note_type" do
      before do
        xhr :post, :notes_mailer, :feedback_mail => {:note_type => 'bogus', :email => 'a@b.com'}
        @resp = JSON::parse(response.body)
      end
      it{expect(response).to be_4xx}
      it "response reports 'invalid note type'" do
        expect(@resp['errors']).to have_key 'note_type'
      end
    end

    describe "submission given note_type email_list and email only" do
      before do
        xhr :post, :notes_mailer, :feedback_mail => {:note_type => 'email_list', :email => 'a@b.com'}
        @resp = JSON::parse(response.body)
      end
      it_should_behave_like "has some invalid params"
      it "response reports errors about email" do
        expect(@resp['errors']).to have_key 'base'
        expect(@resp['errors']).to have_key 'email_confirm'
      end
    end

    describe "submission given note_type feedlink with email only" do
      before do
        xhr :post, :notes_mailer, :feedback_mail => {:note_type => 'feed_submission', :email => 'a@b.com'}
        @resp = JSON::parse(response.body)
      end
      it "response reports errors about missing link" do
        expect(@resp['errors']).to have_key 'feedlink'
      end
    end

    describe "submission given note_type inquiry and email only" do
      before do
        xhr :post, :notes_mailer, :feedback_mail => {:note_type => 'inquiry', :email => 'a@b.com'}
        @resp = JSON::parse(response.body)
      end
      it_should_behave_like "has some invalid params"
      it "response reports 'Email confirm cant be blank'" do
        expect(@resp['errors']).to have_key 'base'
        expect(@resp['errors']).to have_key 'email_confirm'
      end
      it "response reports 'note cannot be empty'" do
        expect(@resp['errors']).to have_key 'inquiry'
      end
    end

    describe "submission given note_type inquiry, both emails but no inquiry" do
      before do
        xhr :post, :notes_mailer, :feedback_mail => {:note_type => 'inquiry',
          :email => 'a@b.com', :email_confirm => 'a@b.com'}
        @resp = JSON::parse(response.body)
      end
      it_should_behave_like "has some invalid params"
      it 'has an error on inquiry' do
        expect(@resp['errors']).to have_key 'inquiry'
      end
    end

    describe "submission with valid params" do
      context "email_list" do
        before do
          xhr :post, :notes_mailer, :feedback_mail => {:note_type => 'email_list',
            :email => 'a@b.com', :email_confirm => 'a@b.com'}
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
          xhr :post, :notes_mailer, :feedback_mail => {:note_type => 'email_list',
            :email => 'a@b.com', :email_confirm => 'a@b.com'}
        end
        it 'adds a feedback item to the db' do
          expect {
            xhr :post, :notes_mailer, :feedback_mail => {:note_type => 'email_list',
              :email => 'a@b.com', :email_confirm => 'a@b.com'}
          }.to change(Feedback, :count).by(1)
        end
      end
      context "inquiry" do
        before do
          xhr :post, :notes_mailer, :feedback_mail => {:note_type => 'inquiry',
            :inquiry => 'cool note',
            :email => 'a@b.com', :email_confirm => 'a@b.com'}
          @resp = JSON::parse(response.body)
        end
        it_should_behave_like 'successful notes mailer response'
      end

      context "help" do
        before do
          xhr :post, :notes_mailer, :feedback_mail => {:note_type => 'help',
            :inquiry => 'cool note',
            :email => 'a@b.com', :email_confirm => 'a@b.com'}
          @resp = JSON::parse(response.body)
        end
        it_should_behave_like 'successful notes mailer response'
      end
      context "feeds link" do
        before do
          xhr :post, :notes_mailer, :feedback_mail => {:note_type => 'feed_submission',
            :feedlink => 'http://feed/feed.rss'}
          @resp = JSON::parse(response.body)
        end
        it_should_behave_like 'successful notes mailer response'

        it 'triggers FeedbackMailer.deliver_feedback' do
          FeedbackMailer.should_receive(:feedback).with() do |f|
            f.login.should eql 'anon'
            f.comment.should include 'feed.rss'
            f.subject.should eql 'MAU Submit Form : feed_submission'
          end.and_return(double(:deliver! => true))

          xhr :post, :notes_mailer, :feedback_mail => {:note_type => 'feed_submission',
            :feedlink => 'http://feed/feed.rss'}
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
      expect(response).to be_success
    end
  end

  describe 'version' do
    it 'returns the app version' do
      get :version
      response.body.should include ApplicationController::VERSION
    end
  end

  describe 'sampler' do
    before do
      get :sampler
    end
    it 'grabs some random pieces' do
      assigns(:rand_pieces).should have_at_least(1).piece
      assigns(:rand_pieces).map(&:class).uniq.should eql [ArtPiecePresenter]
    end

    it 'renders the thumbs partial' do
      expect(response).to render_template 'thumbs'
    end
  end
end
