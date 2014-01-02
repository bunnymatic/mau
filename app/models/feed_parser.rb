require 'open-uri'
require 'rss/2.0'

class FeedParser

  NUM_POSTS = 3

  attr_accessor :options, :url, :link, :num_entries, :strip_tags, :include_date, :truncate, :css_class

  def initialize(url, link, opts)
    @url = URI.parse(url)
    @link = link
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

  def fetch
    logger = ::Rails.logger
    logger.info("FeedsHelper: fetch/format %s posts." % @num_entries)
    feedcontent = ''
    begin
      logger.info("FeedsHelper: open #{@url}")
      open(@url) do |http|
       if @url.host.include? 'twitter'
          result = TwitterFeed.new(http.read)
        else
          result = RSS::Parser.parse(http.read, false)
        end
        if result
          headclass = 'feed-sxn-hdr'
          startdiv = "<div class='%s'>" % headclass
          startlink = ""
          endlink = ""
          if @link
            startlink = "<a target='_blank' href='%s'>" % @link
            endlink = "</a>"
          end
          titlestr = result.channel.title
          iconclass = get_icon_class(@url.host)
          icon = "<div class='feed-icon %s'></div>" % iconclass
          hdr = "%s%s%s%s%s</div>" % [ startdiv, startlink, titlestr, icon, endlink]
          feedcontent += "<div class='feed-entries'>"
          feedcontent += hdr
          num = [result.items.length, num_entries].min
          result.items.first(num).each_with_index do |entry, idx|
            xtra_class = (0==(idx % 2)) ? "odd":"even"
            feedcontent += parse_entry(entry, @link, xtra_class)
          end
          feedcontent += "</div>"
        end
      end
    rescue OpenURI::HTTPError => http
      puts "FeedsHelper: failed to open/parse feed " + http.to_s
      puts "FeedsHelper: skipping to the next"
      feedcontent = ''
    rescue Exception => e
      puts "FeedsHelper: failed to open/parse feed " + e.to_s
      raise
    end
    feedcontent
  end

  private
  def parse_entry(source_entry, link, css_class)

    if ! source_entry
      return "<div class='feedentry'></div>"
    end

    entry = FeedEntry.new(source_entry, link, @strip_tags, @truncate)

    feed = "<div class='feedentry  #{css_class}'>"
    if @include_date
      feed += "<span class='feeddate'>%s</span>" % entry.date
    end

    feed += "<div class='feedtitle'>%s</div>" % entry.title if entry.title.present?
    feed += "<div class='feedtxt'>%s</div>" % entry.description if entry.description.present?
    feed += "</div>"
    feed
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
