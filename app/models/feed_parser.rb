require 'open-uri'
require 'rss/2.0'

class FeedParser

  NUM_POSTS = 3
  DESCRIPTION_LENGTH = 600
  TITLE_LENGTH = 140

  attr_accessor :options, :url, :link

  def initialize(url, link, opts)
    @url = URI.parse(url)
    @link = link
    @options = {
      :numentries => NUM_POSTS,
      :strip_tags => true,
      :include_date => false,
      :truncate => true,
      :css_class => ''
    }.merge(opts)
  end

  def parse_entry(entry, link, css_class)
    strip_tags = @options[:strip_tags]
    include_date = @options[:include_date]
    truncate = @options[:truncate]
    if ! entry
      return "<div class='feedentry'></div>"
    end
    # process entry if we want to.
    if strip_tags
      entry.description.gsub!(@@DESC_CLEANER," ")
    end

    entry.description.strip!
    entry.title.strip!
    title = entry.title
    desc = entry.description
    feed = "<div class='feedentry  #{css_class}'>"
    if include_date
      feed += "<span class='feeddate'>%s</span>" % entry.date
    end

    if truncate
      title = title.truncate TITLE_LENGTH if title
    end

    if (!@link.include? 'twitter') && truncate
      desc = desc.truncate DESCRIPTION_LENGTH
    end

    feed += "<div class='feedtitle'>%s</div>" % title if title
    feed += "<div class='feedtxt'>%s</div>" % desc if desc
    feed += "</div>"
    feed
  end

  def fetch
    numentries = @options[:numentries]

    logger = ::Rails.logger
    logger.info("FeedsHelper: fetch/format %s posts." % numentries)
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
          num = [result.items.length, numentries].min - 1
          result.items[0..num].each_with_index do |entry, idx|
            xtra_class = (0==(idx % 2)) ? "odd":"even"
            feedcontent += parse_entry(entry, @link, xtra_class)
          end
          feedcontent += "</div>"
        end
        logger.info("FeedsHelper: done")
      end
    rescue OpenURI::HTTPError => http
      logger.warn("FeedsHelper: failed to open/parse feed " + http.to_s)
      logger.warn("FeedsHelper: skipping to the next")
      feedcontent = ''
    rescue Exception => e
      logger.warn("FeedsHelper: failed to open/parse feed " + e.to_s)
      raise
    end
    feedcontent
  end

  @@URLMATCH_TO_CLASS = { 'facebook.com' => 'facebook',
    'flickr.com' => 'flickr',
    'livejournal.com' => 'livejournal',
    'twitter.com' => 'twitter',
    'wordpress.com' => 'wordpress',
    'missionlocal.com' => 'wordpress',
    'blogger.com' => 'blogger',
    'blogspot.com' => 'blogger',
    'deviantart.com' => 'deviantart',
    'flaxart.com' => 'flaxart' }

  @@DESC_CLEANER = Regexp.new(/<\/?[^>]*>/)

  @@LINK_MATCH = Regexp.new( '\b(([\w-]+://?|www[.])[^\s()<>]+(?:\([\w\d]+\)|([^[:punct:]\s]|/)))')
#'((http?:\/\/|www\.)([-\w\.]+)+(:\d+)?(\/([\w\/_\.]*(\?\S+)?)?)?)')

  def get_icon_class(url)
    # guess icon class based on url.
    # default is rss
    @@URLMATCH_TO_CLASS.each do |k,v|
      if url.include? k
        return v
      end
    end
    'rss'
  end

end
