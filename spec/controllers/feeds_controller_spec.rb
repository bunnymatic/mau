require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FeedsController do
  # NOTE: we haven't stubbed out the server net calls which we should probably do
  cache_filename = '_cached_feeds.html'
  context "without cache" do
    before do
      Rails.cache.stubs(:read => nil, :write => false, :delete => nil)
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
    it 'if we call it again (assuming cache is expired), we should get a different file' do
      before_sz = File.size(cache_filename)
      get :feed
      File.size(cache_filename).should_not == before_sz
    end
  end
  context "without cache" do
    before do
      Rails.cache.stubs(:read => 'this and that')
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
      File.open(cache_filename).read.should == 'this and that'
    end
    it 'if we call it again, we should get the same' do
      before_sz = File.size(cache_filename)
      get :feed
      File.size(cache_filename).should == before_sz
    end
    it 'does not call the Feeds fetch routine' do
      FeedsHelper.expects(:fetch_and_format_feed).never
      get :feed
    end
  end

end

