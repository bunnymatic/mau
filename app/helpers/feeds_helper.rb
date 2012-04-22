require 'lib/twitter'
NUM_POSTS = 3
DESCRIPTION_LENGTH = 600
TITLE_LENGTH = 140

module FeedsHelper
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


  def parse_entry(entry, link, opts)
    options = { :strip_tags => true,
      :include_date => false,
      :truncate => true, 
      :css_class => ''}.merge(opts)
    strip_tags = options[:strip_tags]
    include_date = options[:include_date]
    truncate = options[:truncate]
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
    feed = "<div class='feedentry  #{options[:css_class]}'>"
    if include_date
      feed += "<span class='feeddate'>%s</span>" % entry.date
    end

    if !link.include? 'twitter'
      if truncate
        title = StringHelpers.trunc(title, TITLE_LENGTH)
        desc = StringHelpers.trunc(desc, DESCRIPTION_LENGTH)
      end
      if title 
        feed += "<div class='feedtitle'>%s</div>" % title
      end
      if desc
        feed += "<div class='feedtxt'>%s</div>" % desc
      end
    else
      if title
        if truncate
          title = StringHelpers.trunc(title, TITLE_LENGTH)
        end
        # replace links with links
        feed += "<div class='feedtxt'>%s</div>" % title
      end
    end
    feed += "</div>"
    feed
    
  end

  def fetch_and_format_feed(url, link, opts = {})
    options = { :numentries => NUM_POSTS, 
      :strip_tags => true, 
      :include_date => false, 
      :truncate => true }.merge(opts)
    numentries = options[:numentries]

    logger = RAILS_DEFAULT_LOGGER
    logger.info("FeedsHelper: fetch/format %s posts." % numentries)
    feedcontent = ''
    begin
      logger.info("FeedsHelper: open " + url)
      open(url) do |http|
        if url.include? 'twitter'
          result = TwitterFeed.new(http.read)
        else
          result = RSS::Parser.parse(http.read, false)
        end
        if result
          headclass = 'feed-sxn-hdr'
          startdiv = "<div class='%s'>" % headclass
          startlink = ""
          endlink = ""
          if link
            startlink = "<a target='_blank' href='%s'>" % link
            endlink = "</a>"
          end
          titlestr = result.channel.title
          iconclass = get_icon_class(url)
          icon = "<div class='feed-icon %s'></div>" % iconclass
          hdr = "%s%s%s%s%s</div>" % [ startdiv, startlink, titlestr, icon, endlink]
          feedcontent += "<div class='feed-entries'>"
          feedcontent += hdr
          num = [result.items.length, numentries].min - 1
          result.items[0..num].each_with_index do |entry, idx|
            xtra_class = (0==(idx % 2)) ? "odd":"even"
            options[:css_class] = xtra_class
            feedcontent += parse_entry(entry, link, options)
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
end
