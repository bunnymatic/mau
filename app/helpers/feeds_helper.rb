NUM_POSTS = 3
DESCRIPTION_LENGTH = 10000
TITLE_LENGTH = 100

module FeedsHelper
  @@URLMATCH_TO_CLASS = { 'facebook.com' => 'facebook',
    'flickr.com' => 'flickr',
    'livejournal.com' => 'livejournal',
    'twitter.com' => 'twitter',
    'wordpress.com' => 'wordpress',
    'blogger.com' => 'blogger',
    'blogspot.com' => 'blogger',
    'deviantart.com' => 'deviantart' }

  @@DESC_CLEANER = Regexp.union( Regexp.new('<br\/?[^>]*>|<br/>'),
                                 Regexp.new('<a\/?[^>]*>|</a>'),
                                 Regexp.new('<img\/?[^>]*>'),
                                 Regexp.new('\s+style=\".*\"\s+' ))

  @@LINK_MATCH = Regexp.new( '\b(([\w-]+://?|www[.])[^\s()<>]+(?:\([\w\d]+\)|([^[:punct:]\s]|/)))')
#'((http?:\/\/|www\.)([-\w\.]+)+(:\d+)?(\/([\w\/_\.]*(\?\S+)?)?)?)')

  def self.get_icon_class(url)
    # guess icon class based on url.
    # default is rss
    @@URLMATCH_TO_CLASS.each do |k,v|
      if url.include? k
        return v
      end
    end
    'rss'
  end

  def self.trunc(msg, num_chars="100", ellipsis=true)
    # truncate string to num_chars
    # add ellipsis if ellipsis=true
    # num_chars includes ellipsis
    if msg.length < num_chars
      return msg
    end
    num_chars = num_chars - 1
    if ellipsis
      num_chars = num_chars - 3
    end
    if num_chars < 0
      return ""
    end
    msg = msg[0..num_chars]
    if ellipsis
      "%s..." % msg
    else
      msg
    end
  end   


  def self.parse_entry(entry, link, strip_tags, include_date, truncate)
    if ! entry
      return "<div class='feedentry'></div>"
    end
    # process entry if we want to.
    if strip_tags
      entry.description.gsub!(@@DESC_CLEANER,"")
    end
    
    entry.description.strip!
    entry.title.strip!
    title = entry.title
    desc = entry.description
    feed = "<div class='feedentry'>"

    if !link.include? 'twitter'
      if truncate
        title = FeedsHelper.trunc(title, TITLE_LENGTH)
        desc = FeedsHelper.trunc(desc, DESCRIPTION_LENGTH)
      end
      if title 
        feed += "<div class='feedtitle'>%s" % title
        if include_date
          feed += "<span class='feeddate'>%s</span>" % entry.date
        end
        feed += "</div>"
      end
      if desc
        feed += "<div class='feedtxt'>%s</div>" % desc
      end
    else
      if title
        title.gsub!(Regexp.new('^\w+\:'),'')
        if truncate
          title = FeedsHelper.trunc(title, TITLE_LENGTH)
        end
        # replace links with links
        title.gsub!(@@LINK_MATCH, '<a target="_blank" class="feed-inner-link" href="\1">\1</a>'))
        feed += "<div class='feedtxt'>%s</div>" % title
      end
    end
    feed += "</div>"
    feed
  end

  def self.fetch_and_format_feed(url, link, numentries=NUM_POSTS, strip_tags=true, include_date=false, truncate=false)
    logger = RAILS_DEFAULT_LOGGER
    logger.info("FeedsHelper: fetch/format %s posts.  Strip? %s" % [ numentries, strip_tags])
    feedcontent = ''
    begin
      logger.info("FeedsHelper: open " + url)
      open(url) do |http|
        result = RSS::Parser.parse(http.read)
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
          if url.include? 'twitter'
            titlestr = link.gsub('http://twitter.com/','Twitter:')
            titlestr.gsub!('http://www.twitter.com/','Twitter:')
          end
          iconclass = get_icon_class(url)
          icon = "<div id='feed_icon' class='%s'></div>" % iconclass
          hdr = "%s%s%s%s%s</div>" % [ startdiv, startlink, titlestr, icon, endlink]
          feedcontent += "<div class='feed-entries'>"
          feedcontent += hdr
          num = [result.items.length, numentries].min - 1
          result.items[0..num].each do |entry|
            feedcontent += parse_entry(entry, link, strip_tags, include_date, truncate)
          end
          feedcontent += "</div>"
        end
        logger.info("FeedsHelper: done") 
      end
    rescue Exception => e
      logger.warn("FeedsHelper: failed to open/parse feed " + e.to_s)
    end
    feedcontent
  end
end
