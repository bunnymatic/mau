require 'rand_helpers'
require 'open-uri'
require 'rss/1.0'
require 'rss/2.0'
require 'ftools'
FEEDS_KEY = 'news-feeds'

class MainController < ApplicationController
  layout 'mau2col'
  before_filter :load_studios
  before_filter :no_cache, :only => :index
  @@CACHE_EXPIRY = (Conf.cache_expiry['feed'] or 20)
  def index
    @rand_pieces = MainHelper.get_random_pieces
    @page_title = "Mission Artists United"
  end

  def version
    file = File.expand_path('VERSION')
    f = open(file,'r')
    render :text => f.read
  end

  def about
    @show_history = false
    if params[:id] == 'h'
      @show_history = true
    end
    @page_title = "Mission Artists United - About Us"
  end
  
  def news
    @feedhtml = ''
    numentries = 5
    url, link = 'http://missionartistsunited.wordpress.com/feed/',
    'http://missionartistsunited.wordpress.com'
    begin
      cached_html = CACHE.get(FEEDS_KEY)
      if not cached_html
        print 'cache miss'
      end
    rescue
      cached_html = nil
    end
    if !cached_html or cached_html.empty?
      cached_html = FeedsHelper.fetch_and_format_feed(url, link, 5, true, true, false)
      begin
        CACHE.set(FEEDS_KEY, cached_html, @@CACHE_EXPIRY)
      rescue
        nil
      end
    end
    @page_title = "Mission Artists United News"
    @feedhtml = cached_html
  end
end
