require 'spec_helper'

describe ArtistFeedsController do
  fixtures :users, :roles, :artist_feeds, :roles_users

  let(:url) { 'http://this.url' }
  let(:feed_url) { 'http://this.url/feed?rss=true' }
  let(:active) { true }
  let(:feed_attrs) { {:url => url, :feed => feed_url, :active => active } }

  shared_examples_for 'artist feeds controller new or edit' do
    it { expect(response).to be_success }
    it "renders new or edit template" do
      expect(response).to render_template 'new_or_edit'
    end
    it 'has time fields for start/end and reception start/end' do
      assert_select('input#artist_feed_url')
      assert_select('input#artist_feed_feed')
      assert_select('input#artist_feed_active')
    end
  end

  context 'not authorized' do
    [:index, :edit, :update].each do |meth|
      context "#{meth}" do
        before do
          get meth, :id => 'whatever'
        end
        it_should_behave_like "not authorized"
      end
    end
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
      it { expect(response).to be_success }
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
      it { expect(response).to be_success }
    end
    describe '#new' do
      before do
        get :new
      end
      it { expect(response).to be_success }
    end
    describe '#create' do
      context 'good params' do
        before do
          post :create, :artist_feed => feed_attrs
        end
        it 'redirects to index' do
          expect(response).to redirect_to artist_feeds_path
        end
        it 'creates the item' do
          feed = ArtistFeed.where(:url => url).first
          expect(feed.feed).to eql feed_url
          expect(feed.active).to eql true
        end
      end
      context 'bad inputs' do
        let(:url) { 'h' }
        render_views
        before do
          post :create, :artist_feed => feed_attrs
        end
        it 'renders the form' do
          expect(response).to render_template 'new_or_edit'
        end
        it 'renders the errors' do
          assert_select '.error-msg', /too short/
        end
      end
    end
    describe '#update' do
      context 'with good data' do
        before do
          post :update, :id => artist_feeds(:inactive).id, :artist_feed => feed_attrs
        end
        it 'redirects to index' do
          expect(response).to redirect_to artist_feeds_path
        end
        it 'updates the item' do
          feed = ArtistFeed.find(artist_feeds(:inactive).id)
          expect(feed.url).to eql url
          expect(feed.feed).to eql feed_url
          expect(feed.active).to eql true
        end
      end
      context 'with bad data' do
        before do
          post :update, :id => artist_feeds(:inactive).id, :artist_feed => {:url => nil}
        end
        it 'redirects to index' do
          expect(response).to render_template 'new_or_edit'
        end
        it 'sets errors on the feed' do
          expect(assigns(:feed).errors).to have_at_least(1).error
        end
      end
    end

    describe "#destroy" do
      it "destroys and redirects" do
        expect{
          delete :destroy, :id => ArtistFeed.first.id
          expect(response).to redirect_to artist_feeds_url
        }.to change(ArtistFeed,:count).by(-1)
      end
    end

  end
end
