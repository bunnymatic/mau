require 'spec_helper'

include AuthenticatedTestHelper

describe ArtistFeedsController do
  fixtures :users, :roles, :artist_feeds, :roles_users

  shared_examples_for 'artist feeds controller new or edit' do
    it { response.should be_success }
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

  describe 'as admin' do
    render_views
    before do
      login_as(:admin)
    end
    describe '#index' do
      before do
        get :index
      end
      it { response.should be_success }
      it 'has edit link for each feed' do
        ArtistFeed.all.each do |feed|
          assert_select ".feed_entry .controls a[href=/artist_feeds/#{feed.id}/edit]", 'edit'
        end
      end
      it 'has remove link for each feed' do
        ArtistFeed.all.each do |feed|
          assert_select ".feed_entry .controls a[href=/artist_feeds/#{feed.id}]", 'remove'
        end
      end
      it 'has the url and feed shown for each feed' do
        ArtistFeed.all.each do |feed|
          assert_select ".feed_entry .url", feed.url
          assert_select ".feed_entry .feed", feed.feed
        end
      end
    end
    describe '#edit' do
      before do
        get :edit, :id => artist_feeds(:twitter)
      end
      it { response.should be_success }
    end
    describe '#new' do
      before do
        get :new
      end
      it { response.should be_success }
    end
    describe '#create' do
      context 'good params' do
        before do
          post :create, {:artist_feed => {:url => 'http://this.url', :feed => 'http://this.url/feed?rss=true', :active => true}}
        end
        it 'redirects to index' do
          response.should redirect_to artist_feeds_path
        end
        it 'creates the item' do
          feed = ArtistFeed.where(:url => 'http://this.url').first
          feed.should be
          feed.feed.should eql 'http://this.url/feed?rss=true'
          feed.active.should be_present
        end
      end
      context 'bad inputs' do
        render_views
        before do
          post :create, {:artist_feed => {:url => 'h', :feed => 'http://this.url/feed?rss=true', :active => true}}
        end
        it 'renders the form' do
          response.should render_template 'new_or_edit'
        end
        it 'renders the errors' do
          assert_select '.error-msg', /too short/
        end
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
        feed.url.should eql 'http://this.url'
        feed.feed.should eql 'http://this.url/feed?rss=true'
        feed.active.should be_present
      end
    end

    describe "#destroy" do
      it "destroys and redirects" do
        expect{
          delete :destroy, :id => ArtistFeed.first.id
          response.should redirect_to artist_feeds_url
        }.to change(ArtistFeed,:count).by(-1)
      end
    end

  end
end
