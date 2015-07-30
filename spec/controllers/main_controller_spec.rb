require 'spec_helper'

shared_examples_for "successful notes mailer response" do
  it { expect(response).to be_success }
  it { expect(JSON.parse(response.body)['success']).to eql true }
end

shared_examples_for 'has some invalid params' do
  it{expect(response).to be_4xx}
  it { expect(JSON.parse(response.body)['success']).to eql false }
  it { expect(JSON.parse(response.body)['error_messages']).to be_present }
end

describe MainController do

  let(:fan) { FactoryGirl.create(:fan, :active) }
  let(:editor) { FactoryGirl.create(:artist, :active, :editor) }
  let(:admin) { FactoryGirl.create(:artist, :admin) }
  let(:artist) { FactoryGirl.create(:artist, :active, :with_art) }
  let(:prolific_artist) { FactoryGirl.create(:artist, :active, :with_art, number_of_art_pieces: 15) }

  before do
    # seems like we have leaky database records
    fix_leaky_fixtures
    artist
    prolific_artist
    FactoryGirl.create(:open_studios_event, :future)
  end

  describe "#index" do
    render_views
    context 'not logged in' do
      before do
        get :index
      end
      it 'has the default description & keywords' do
        assert_select 'head meta[name=description]' do |desc|
          desc.length.should eql 1
          desc[0].attributes['content'].should match /^Mission Artists United is a website/
        end
        assert_select 'head meta[property=og:description]' do |desc|
          desc.length.should eql 1
          desc[0].attributes['content'].should match /^Mission Artists United is a website/
        end
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
  end

  describe "#news" do
    before do
      get :resources
    end
    it { expect(response).to be_success }
  end

  describe "#about" do
    context "while not logged in" do
      before do
        FactoryGirl.create(:cms_document, page: :main, section: :about)
        get :about
      end
      it { expect(response).to be_success }
      it 'fetches markdown content' do
        assigns(:content).should have_key :content
        assigns(:content).should have_key :cmsid
      end
    end
  end

  describe "#getinvolved" do
    it "returns success" do
      get :getinvolved
      expect(response).to be_success
    end
    describe '/paypal_success' do
      render_views
      before do
        post :getinvolved, :p => 'paypal_success'
      end
      it { expect(response).to be_success }
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
      it { expect(response).to be_success }
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
          login_as artist
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
    before do
      get :privacy
    end
    it { expect(response).to be_success }
  end

  describe "#faq" do
    before do
      get :faq
    end
    it { expect(response).to be_success }
  end

  describe '#main/venues' do
    render_views
    context "while not logged in" do
      before do
        get :venues
      end
      it { expect(response).to be_success }
    end
    context 'logged in as admin' do
      let(:venue_doc) {FactoryGirl.create(:cms_document,
                                          page: :venues,
                                          section: :all,
                                          article: "# these \n\n## are \n\n### venues \n\n* one\n* two\n* three"
                                          )}
      before do
        venue_doc
        login_as(admin)
        get :venues
      end
      it "renders the markdown version" do
        assert_select '.markdown h1', :match => 'these'
        assert_select '.markdown h2', :match => 'are'
        assert_select '.markdown h3', :match => 'venues'
        assert_select '.markdown ul li', :count => 3
      end
      it 'the markdown entry have cms document ids in them' do
        assert_select '.markdown.editable[data-cmsid=%s]' % venue_doc.id

      end
    end
  end

  describe 'notes mailer' do
    before do
      FeedbackMailer.any_instance.stub(:deliver! => true)
    end
    describe "xhr post" do
      before do
        xhr :post, :notes_mailer, feedback_mail: { stuff: 'whatever'}
        @resp = JSON::parse(response.body)
      end
      it{expect(response).to be_4xx}
      it "response reports 'invalid note type'" do
        expect(@resp['error_messages']).to include "Email can't be blank"
        expect(@resp['error_messages']).to include "Email confirm can't be blank"
        expect(@resp['error_messages']).to include "Note type  is not a valid note type"
      end
    end

    describe "submission given invalid note_type" do
      before do
        xhr :post, :notes_mailer, :feedback_mail => {:note_type => 'bogus', :email => 'a@b.com'}
        @resp = JSON::parse(response.body)
      end
      it{expect(response).to be_4xx}
    end

    describe "submission given note_type email_list and email only" do
      before do
        xhr :post, :notes_mailer, :feedback_mail => {:note_type => 'email_list', :email => 'a@b.com'}
        @resp = JSON::parse(response.body)
      end
      it_should_behave_like "has some invalid params"
    end

    describe "submission given note_type inquiry, both emails but no inquiry" do
      before do
        xhr :post, :notes_mailer, :feedback_mail => {:note_type => 'inquiry',
          :email => 'a@b.com', :email_confirm => 'a@b.com'}
        @resp = JSON::parse(response.body)
      end
      it_should_behave_like "has some invalid params"
    end

    describe "submission with valid params" do
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
    end
  end

  describe 'status' do
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
      response.body.should eql ApplicationController::VERSION
    end
  end

  describe 'sampler' do
    before do
      get :sampler
    end

    it 'renders the thumbs partial' do
      expect(response).to render_template 'main/_sampler_thumb'
    end
  end
end
