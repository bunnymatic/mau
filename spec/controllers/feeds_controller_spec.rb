require 'spec_helper'

include AuthenticatedTestHelper

describe FeedsController do
  # NOTE: we haven't stubbed out the server net calls which we should probably do
  fixtures :artist_feeds, :users, :roles_users, :roles
  cache_filename = '_cached_feeds.html'

  context 'with bad feed data' do
    it 'handles failure in fetch and format' do
      VCR.use_cassette('twitter') do

        controller.stub(:random_feeds => [artist_feeds(:twitter)])
        if File.exists?(cache_filename)
          File.delete(cache_filename)
        end
        get :feed
        response.should be_success
      end
    end
  end

  context "without cache" do
    before do
      VCR.use_cassette('flaxart') do
        controller.stub(:random_feeds => [artist_feeds(:flaxart)])
        Rails.cache.stub(:read => nil, :write => false, :delete => nil)
        if File.exists?(cache_filename)
          File.delete(cache_filename)
        end
        get :feed
      end
    end

    it 'returns success' do
      response.should be_success
    end
    it 'writes a file called _cached_feeds.html' do
      File.exists?(cache_filename).should be
    end
    it 'if we call it again (assuming cache is expired), we should get a different file' do
      before_contents = File.open(cache_filename).read
      tweet_response = [ { :user => {:screen_name => 'blurp'},
                           :text => "I tweeted this #{Faker::Lorem.words(5).join(' ')}",
                           :created_at => (Time.zone.now - (rand(10)).days).to_s } ]
      mock_readable = double(:read => tweet_response.to_json)
      MauFeed::Parser.any_instance.stub(:open).and_yield(mock_readable)
      get :feed
      File.open(cache_filename).read.should_not eql before_contents
    end
    it 'it should include text from the feed' do
      File.open(cache_filename).read.should include 'FLAX art'
    end
  end
  context "with cache" do
    before do
      Rails.cache.stub(:read => 'this and that', :write => nil, :delete => nil)
      if File.exists?(cache_filename)
        File.delete(cache_filename)
      end
      get :feed
    end

    it 'returns success' do
      response.should be_success
    end
    it 'writes a file called _cached_feeds.html' do
      File.exists?(cache_filename).should be
    end
    it 'file contains the text "this and that"' do
      File.open(cache_filename).read.should eql 'this and that'
    end
    it 'if we call it again, we should get the same' do
      before_sz = File.size(cache_filename)
      get :feed
      File.size(cache_filename).should eql before_sz
    end
    it 'does not call the Feeds fetch routine' do
      FeedsController.any_instance.should_receive(:fetch_and_format_feed).never
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
        login_as(:artist1)
        get :clear_cache
      end
      it_should_behave_like 'not authorized'
    end
    describe 'as admin' do
      before do
        login_as(:admin)
      end
      it 'dumps the cache file' do
        File.exists?(cache_filename).should be
        Rails.cache.should_receive(:delete)
        File.should_receive(:delete).with('_cached_feeds.html')
        FeedsController.any_instance.stub(:fetch_feeds)
        get :clear_cache
      end
    end
  end
end
