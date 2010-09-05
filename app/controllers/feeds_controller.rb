require 'memcache'
require 'open-uri'
require 'rss/2.0'
require 'string_helpers'

class FeedsController < ApplicationController

  @@CACHE_EXPIRY = (Conf.cache_expiry['feed'] or 4000)
  @@FEEDS_KEY = (Conf.cache_ns or '') + 'sb-feeds'
  @@FEED_KEY = (Conf.cache_ns or '') + 'sb-feed'
  @@NUM_FEEDS = 4

  def index
  end

  def feed
    allfeeds = ''
    numentries = params[:numentries].to_i or 2
    page = ''
    if !params[:page].empty?
      page = params[:page]
    end
    begin
      cached_html = Rails.cache.read(@@FEEDS_KEY)
      if !cached_html or cached_html.empty?
        logger.info("FeedController: cache miss\n")
      else
        logger.info("FeedController: fetched feeds from cache\n")
      end
    rescue Exception => ex
      cached_html = ""
      p ex
      logger.error(ex)
    end
    if !cached_html or cached_html.empty? 
      logger.info("FeedController: fetch feeds\n")
      feedurls = []
      # pairs here are the feed url and the link url

      # don't show mau news on the feed if we're on the news page
      feeds = Conf.feeds_urls
      strip_tags = true
      choice(feeds, @@NUM_FEEDS).each do |ff|
        allfeeds += FeedsHelper.fetch_and_format_feed(ff['feed'], ff['url'], numentries, true, false, true)
      end
      begin
        logger.info("FeedController: add feed to cache(expiry %d)" % @@CACHE_EXPIRY)
        Rails.cache.write(@@FEEDS_KEY, allfeeds, :expires_in => @@CACHE_EXPIRY)
      rescue Exception => ex
        logger.error("FeedController: failed to add to the cache")
        p ex
      end
    else
      allfeeds = cached_html
    end
    allfeeds = "<div class='feed-sxn-hdr'>MAU Artist Feeds</div>" + allfeeds
    logger.debug("FeedController: render")
    if allfeeds.empty?
      render :action => 'default_feeds'
      logger.debug("FeedController: fail")
    else
      render :text => allfeeds
    end
  end

end
