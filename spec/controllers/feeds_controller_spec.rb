require 'spec_helper'

describe FeedsController do
  # NOTE: we haven't stubbed out the server net calls which we should probably do

  cache_filename = '_cached_feeds.html'

  let(:artist) { FactoryGirl.create(:artist, :active) }
  let(:admin) { FactoryGirl.create(:artist, :admin) }

  let(:flax_feed) { FactoryGirl.create(:artist_feed,
                                       feed: "http://flaxart.com/feed",
                                       url: "http://flaxart.com",
                                       active: true) }
  let(:twitter_feed) { FactoryGirl.create(:artist_feed,
                                          feed: "https://twitter.com/statuses/user_timeline/62131363.json",
                                          url: "http://twitter.com/sfmau",
                                          active: true ) }
  context 'with bad feed data' do
    it 'handles failure in fetch and format' do
      VCR.use_cassette('twitter') do

        controller.stub(:random_feeds => [twitter_feed])
        if File.exists?(cache_filename)
          File.delete(cache_filename)
        end
        get :feed
        expect(response).to be_success
      end
    end
  end

  context "without cache" do
    context 'normal operation' do
      before do
        VCR.use_cassette('artist_feeds') do
          Rails.cache.stub(:read => nil, :write => false, :delete => nil)
          if File.exists?(cache_filename)
            File.delete(cache_filename)
          end
          get :feed
        end
      end

      it 'returns success' do
        expect(response).to be_success
      end
      it 'writes a file called _cached_feeds.html' do
        expect(File.exists?(cache_filename)).to be
      end
    end

    context 'checking contents' do
      before do
        VCR.use_cassette('flaxart') do
          controller.stub(:random_feeds => [flax_feed])
          Rails.cache.stub(:read => nil, :write => false, :delete => nil)
          if File.exists?(cache_filename)
            File.delete(cache_filename)
          end
          get :feed
        end
      end
      it 'if we call it again (assuming cache is expired), we should get a different file' do
        before_contents = File.open(cache_filename).read
        tweet_response = [ { :user => {:screen_name => 'blurp'},
                             :text => "I tweeted this #{Faker::Lorem.words(5).join(' ')}",
                             :created_at => (Time.zone.now - (rand(10)).days).to_s } ]
        mock_readable = double(:read => tweet_response.to_json)
        allow_any_instance_of(MauFeed::Parser).to receive(:open).and_yield(mock_readable)
        get :feed
        expect(File.open(cache_filename).read).not_to eql before_contents
      end
      it 'it should include text from the feed' do
        expect(File.open(cache_filename).read).to include 'FLAX art'
      end
    end
  end
  context "with cache" do
    before do
      create(:artist_feed, active: true)
      mock_parser = double(MauFeed::Parser, feed_content: 'this and that')
      allow(MauFeed::Parser).to receive(:new).and_return(mock_parser)
      if File.exists?(cache_filename)
        File.delete(cache_filename)
      end
      get :feed
    end

    it 'returns success' do
      expect(response).to be_success
    end
    it 'writes a file called _cached_feeds.html' do
      expect(File.exists?(cache_filename)).to be
    end
    it 'file contains the text "this and that"' do
      expect(File.open(cache_filename).read).to eql 'this and that'
    end
    it 'if we call it again, we should get the same' do
      before_sz = File.size(cache_filename)
      get :feed
      expect(File.size(cache_filename)).to eql before_sz
    end
    it 'does not call the Feeds fetch routine' do
      expect_any_instance_of(FeedsController).to receive(:fetch_and_format_feed).never
      get :feed
    end
  end

  describe '#clear_cache' do
    describe 'not logged in' do
      before do
        get :clear_cache
      end
      it_should_behave_like 'not authorized'
    end
    describe 'logged in as user' do
      before do
        login_as artist
        get :clear_cache
      end
      it_should_behave_like 'not authorized'
    end
    describe 'as admin' do
      before do
        login_as admin
      end
      it 'dumps the cache file' do
        expect(Rails.cache).to receive(:delete)
        expect(File).to receive(:delete).with('_cached_feeds.html')
        allow_any_instance_of(FeedsController).to receive(:fetch_feeds)
        get :clear_cache
      end
    end
  end
end
