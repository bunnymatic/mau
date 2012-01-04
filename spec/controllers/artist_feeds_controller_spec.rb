require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

include AuthenticatedTestHelper

describe ArtistFeedsController do
  fixtures :users, :roles, :artist_feeds

  shared_examples_for 'artist feeds controller new or edit' do
    it "returns success" do
      response.should be_success
    end
    it "renders new or edit template" do
      response.should render_template 'new_or_edit'
    end
    it 'has time fields for start/end and reception start/end' do
      assert_select('input#artist_feed_url')
      assert_select('input#artist_feed_feed')
      assert_select('input#artist_feed_active')
    end
  end

  [:index, :edit, :update].each do |meth|
    before do
      get meth
    end
    it_should_behave_like "not authorized"
  end
  
  describe 'as admin ' do
    integrate_views
    before do
      login_as(:admin)
    end
    describe '#index' do
      before do
        get :index
      end
      it 'returns success' do
        response.should be_success
      end
      it 'has edit link for each feed' do
        ArtistFeed.all.each do |af|
          response.should have_tag (".feed_entry .controls a[href=/artist_feeds/%d/edit]" % af.id), 'edit'
        end
      end
      it 'has remove link for each feed' do
        ArtistFeed.all.each do |af|
          response.should have_tag (".feed_entry .controls a[href=/artist_feeds/%d]" % af.id), 'remove'
        end
      end
      it 'has the url and feed shown for each feed' do
        ArtistFeed.all.each do |af|
          response.should have_tag ".feed_entry .url", af.url
          response.should have_tag ".feed_entry .feed", af.feed
        end
      end
    end
    describe '#edit' do
      before do
        get :edit, :id => artist_feeds(:twitter)
      end
      it 'returns success' do
        response.should be_success
      end
    end
    describe '#new' do
      before do
        get :new
      end
      it 'returns success' do
        response.should be_success
      end
    end
    describe '#create' do
      before do
        post :create, {:artist_feed => {:url => 'http://this.url', :feed => 'http://this.url/feed?rss=true', :active => true}}
      end
      it 'redirects to index' do
        response.should redirect_to artist_feeds_path
      end
      it 'creates the item' do
        feed = ArtistFeed.find_by_url('http://this.url')
        feed.should be
        feed.feed.should == 'http://this.url/feed?rss=true'
        feed.active.should be
      end

    end
    describe '#update' do
      before do
        post :update, {:id => artist_feeds(:inactive).id, :artist_feed => {:url => 'http://this.url', :feed => 'http://this.url/feed?rss=true', :active => true}}
      end
      it 'redirects to index' do
        response.should redirect_to artist_feeds_path
      end
      it 'updates the item' do
        feed = ArtistFeed.find(artist_feeds(:inactive).id)
        feed.url.should == 'http://this.url'
        feed.feed.should == 'http://this.url/feed?rss=true'
        feed.active.should be
      end
    end

  end
end
