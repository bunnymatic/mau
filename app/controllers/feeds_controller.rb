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
    allfeeds = ''
    numentries = params[:numentries].to_i or nil
    page = ''
    cached_html = nil
    if !params[:page].blank?
      page = params[:page]
    end
    begin
      cached_html = SafeCache.read(FEEDS_KEY)
    rescue TypeError
      SafeCache.delete(FEEDS_KEY)
    end
    if !cached_html.present?

      feedurls = []
      # pairs here are the feed url and the link url

      # don't show mau news on the feed if we're on the news page
      feeds = ArtistFeed.active.all
      strip_tags = true
      feeds.sample(NUM_FEEDS).each do |ff|
        next unless ff
        if ff.url.match /twitter.com/
          numentries = 3
        else
          numentries = 1
        end
        begin
          feed_parser = FeedParser.new(ff.feed, ff.url, {:num_entries => numentries})
          feed_content = allfeeds += feed_parser.feed_content
        rescue Exception => ex
          logger.error("Failed to grab feed " + ff.inspect)
          logger.error(ex)
        end
      end
      SafeCache.write(FEEDS_KEY, allfeeds, :expires_in => CACHE_EXPIRY)
      cached_html = allfeeds
    end
    partial = File.open(@@CACHED_FEEDS_FILE, 'w')
    if partial
      partial.write(cached_html.to_s)
      partial.close
    end
  end
end
