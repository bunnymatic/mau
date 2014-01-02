require 'open-uri'
require 'rss/2.0'

class FeedParser

  include  ActionView::Helpers::TagHelper

  NUM_POSTS = 3
  FEED_SECTION_HEADER_CLASS = 'feed-sxn-hdr'

  attr_accessor :options, :url, :feed_link, :num_entries, :strip_tags, :include_date, :truncate, :css_class

  def initialize(source_url, feed_link, opts)
    @source_url = source_url
    @feed_link = feed_link
    options = {
      :num_entries => NUM_POSTS,
      :strip_tags => true,
      :include_date => false,
      :truncate => true,
      :css_class => ''
    }.merge(opts.symbolize_keys)
    @num_entries = options[:num_entries]
    @strip_tags = options[:strip_tags]
    @include_date = options[:include_date]
    @truncate = options[:truncate]
    @css_class = options[:css_class]
  end

  def feed_content
    @feed_content ||=
      begin
        html = header_html
        html << items.map.with_index do |entry, idx|
          xtra_class = (0==(idx % 2)) ? "odd":"even"
          parse_entry(entry, xtra_class)
        end.join("").html_safe
        div(html, :class => 'feed-entries')
      end
  end

  private
  def url
    @url ||= URI.parse(@source_url)
  end

  def is_twitter?
    url.host.include? 'twitter'
  end
  
  def fetched
    @fetched ||=
      begin
        logger = ::Rails.logger
        logger.info("FeedsHelper: fetch/format %s posts." % @num_entries)
        begin
          open(url) do |http|
            if is_twitter?
              TwitterFeed.new(http.read)
            else
              RSS::Parser.parse(http.read, false)
            end
         end
        rescue OpenURI::HTTPError => http
          puts "FeedsHelper: failed to open/parse feed #{url}:" + http.to_s
          puts "FeedsHelper: skipping to the next"
        rescue Exception => e
          puts "FeedsHelper: failed to open/parse feed #{url}:" + e.to_s
          raise
        end
      end
  end

  def link_to_feed
    title = fetched.try(:channel).try(:title)
    if title.present? 
      the_icon = icon(get_icon_class(url.host))
      link_to(title + the_icon, feed_link, :class => FEED_SECTION_HEADER_CLASS).html_safe
    else
      ''
    end
  end

  def link_to(text, link, opts={}) 
    if link.present?
      content_tag(:a, text, opts.merge({:href => link}), false)
    else
      text
    end.html_safe
  end

  def span(text, opts = {})
    content_tag(:span, text, opts, false).html_safe
  end

  def div(text, opts = {})
    content_tag(:div, text, opts, false).html_safe
  end

  def icon(icon_class)
    (div '', :class => "#{icon_class} feed-icon").html_safe
  end

  def header_html
    @header_html = div(link_to_feed)
  end

  def num_available_entries 
    @available_entries ||= fetched.try(:items).try(:length)
  end
  
  def num_items_to_show
    [num_available_entries, num_entries].min
  end

  def items
    @items ||= (fetched ? fetched.items.first(num_items_to_show) : [])
  end

  def parse_entry(source_entry, css_class)

    entry = FeedEntry.new(source_entry, feed_link, @strip_tags, @truncate)

    feed = ''
    if @include_date
      feed << span(entry.date, :class => 'feeddate')
    end

    feed << div(entry.title, :class => 'feedtitle') if entry.title.present?
    feed << div(entry.description, :class => 'feedtxt') if entry.description.present?

    div feed, :class => "feedentry #{css_class}"
  end


  URLMATCH_TO_CLASS = {
    'facebook.com' => 'facebook',
    'flickr.com' => 'flickr',
    'livejournal.com' => 'livejournal',
    'twitter.com' => 'twitter',
    'wordpress.com' => 'wordpress',
    'missionlocal.com' => 'wordpress',
    'blogger.com' => 'blogger',
    'blogspot.com' => 'blogger',
    'deviantart.com' => 'deviantart',
    'flaxart.com' => 'flaxart' }.freeze

  def get_icon_class(url)
    # guess icon class based on url.
    # default is rss
    URLMATCH_TO_CLASS.each do |k,v|
      if url.include? k
        return v
      end
    end
    'rss'
  end

end
