class FeedsController < ApplicationController

  before_filter :admin_required, :only => [ :clear_cache ]

  include FeedsHelper

  CACHE_EXPIRY = (Conf.cache_expiry['feed'] or 4000)
  FEEDS_KEY = 'sb-feeds'
  NUM_FEEDS = 4

  @@CACHED_FEEDS_FILE = '_cached_feeds.html'
  def index
  end

  def clear_cache
    SafeCache.delete(FEEDS_KEY)
    begin
      File.delete(@@CACHED_FEEDS_FILE)
    rescue Exception => ex
    end
    fetch_feeds
    redirect_to request.referer
  end

  def feed
    fetch_feeds
    render :nothing => true
  end

  private
  def fetch_feeds
    feed_html = SafeCache.read(FEEDS_KEY)
    if !feed_html
      feed_html = force_fetch_feeds
    end
    write_local_cache_file(feed_html)
  end

  def random_feeds
    ArtistFeed.active.all.sample(NUM_FEEDS)
  end

  def force_fetch_feeds
    feedurls = []
    feeds_content = random_feeds.map do |feed|
      next unless feed
      num_entries = (feed.is_twitter? ? 3 : 1)
      begin
        feed_parser = FeedParser.new(feed.feed, feed.url, {:num_entries => num_entries})
        feed_parser.feed_content
      rescue Exception => ex
        logger.error("Failed to grab feed " + feed.inspect)
        logger.error(ex)
      end
    end.join
    SafeCache.write(FEEDS_KEY, feeds_content, :expires_in => CACHE_EXPIRY)
    feeds_content
  end

  def write_local_cache_file(feed_html)
    partial = File.open(@@CACHED_FEEDS_FILE, 'w')
    if partial
      partial.write(feed_html.to_s)
      partial.close
    end
  end
end
