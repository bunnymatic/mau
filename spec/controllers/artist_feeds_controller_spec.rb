require 'spec_helper'

include AuthenticatedTestHelper

describe ArtistFeedsController do
  fixtures :users, :roles, :artist_feeds, :roles_users

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
      it { response.should be_success }
      it 'sets the feed_html' do
        assigns(:feed_html).should include "class='feed-entries'"
      end
      it 'draws the feed_html' do
        assert_select '.feed-entries'
      end
      it 'has edit link for each feed' do
        ArtistFeed.all.each do |af|
          assert_select ".feed_entry .controls a[href=/artist_feeds/#{of.id}/edit", 'edit'
        end
      end
      it 'has remove link for each feed' do
        ArtistFeed.all.each do |af|
          assert_select ".feed_entry .controls a[href=/artist_feeds/#{of.id}", 'remove'
        end
      end
      it 'has the url and feed shown for each feed' do
        ArtistFeed.all.each do |af|
          assert_select ".feed_entry .url", af.url
          assert_select ".feed_entry .feed", af.feed
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
