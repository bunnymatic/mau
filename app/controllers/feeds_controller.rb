require 'open-uri'
require 'rss/2.0'
require 'string_helpers'

class FeedsController < ApplicationController

  before_filter :admin_required, :only => [ :clear_cache ]

  include FeedsHelper

  @@CACHE_EXPIRY = (Conf.cache_expiry['feed'] or 4000)
  @@FEEDS_KEY = 'sb-feeds'
  @@NUM_FEEDS = 4

  @@CACHED_FEEDS_FILE = '_cached_feeds.html'
  def index
  end

  def clear_cache
    Rails.cache.delete(@@FEEDS_KEY)
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
      cached_html = Rails.cache.read(@@FEEDS_KEY)
    rescue TypeError
      Rails.cache.delete(@@FEEDS_KEY)
    rescue Exception => ex
      cached_html = ''
      logger.error(ex)
    end
    if !cached_html.present?
      feedurls = []
      # pairs here are the feed url and the link url

      # don't show mau news on the feed if we're on the news page
      feeds = ArtistFeed.active.all
      strip_tags = true
      choice(feeds, @@NUM_FEEDS).each do |ff|
        next unless ff
        if ff.url.match /twitter.com/
          numentries = 3
        else 
          numentries = 1
        end
        begin
          feed_content = allfeeds += fetch_and_format_feed(ff.feed, ff.url, {:numentries => numentries})
          feeds += feed_content
        rescue Exception => ex
          logger.error("Failed to grab feed " + ff.inspect)
        end
      end
      begin
        Rails.cache.write(@@FEEDS_KEY, allfeeds, :expires_in => @@CACHE_EXPIRY)
      rescue Exception => ex
        logger.error("FeedController: failed to add to the cache")
      end
      cached_html = allfeeds
    end
    partial = File.open(@@CACHED_FEEDS_FILE, 'w')
    if partial
      partial.write(cached_html)
      partial.close
    end
  end
end
