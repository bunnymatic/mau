require 'memcache'
require 'open-uri'
require 'rss/2.0'
require 'string_helpers'

class FeedsController < ApplicationController

  before_filter :admin_required, :only => [ :clear_cache ]

  include FeedsHelper

  @@CACHE_EXPIRY = (Conf.cache_expiry['feed'] or 4000)
  @@FEEDS_KEY = (Conf.cache_ns or '') + 'sb-feeds'
  @@FEED_KEY = (Conf.cache_ns or '') + 'sb-feed'
  @@NUM_FEEDS = 4

  @@CACHED_FEEDS_FILE = '_cached_feeds.html'
  def index
  end

  def clear_cache
    Rails.cache.delete(@@FEEDS_KEY)
    if File.exists? @@CACHED_FEEDS_FILE
      File.delete(@@CACHED_FEEDS_FILE)
    end
    redirect_to request.referer
  end

  def feed
    allfeeds = ''
    numentries = params[:numentries].to_i or nil
    page = ''
    cached_html = nil
    if !params[:page].blank?
      page = params[:page]
    end
    begin
      cached_html = Rails.cache.read(@@FEEDS_KEY)
      if !cached_html or cached_html.empty?
        logger.info("FeedController: cache miss\n")
      else
        logger.info("FeedController: fetched feeds from cache\n")
      end
    rescue TypeError
      Rails.cache.delete(@@FEEDS_KEY)
    rescue Exception => ex
      cached_html = nil
      logger.error(ex)
    end
    if !cached_html.present?
      logger.info("FeedController: fetch feeds\n")
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
        allfeeds += fetch_and_format_feed(ff.feed, ff.url, {:numentries => numentries})
      end
      begin
        logger.info("FeedController: add feed to cache(expiry %d)" % @@CACHE_EXPIRY)
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
    render :nothing => true
  end

end
