module ArtPiecesHelper

  def self.compute_pagination(pieces, curpage, perpage)
    # inputs:  all pieces that we want to paginate through as an array
    # curpage:  what page are you on (integer)
    # perpage:  how many results to we show per page
    #
    # return trimmed array of pieces to show, the next page index,
    # previous page index, and booleans indicating whether to show the
    # next link and previous link
    #
    # return as a tuple:
    #    array: pieces to show
    #    int: next page index
    #    int: previous page index
    #    int: last page index
    begin
      ct = pieces.length
    rescue Exception => ex
      ::Rails.logger.warn("Failed to compute length of [%s]" % pieces)
      return nil
    end
    if perpage < 0
      return nil
    end
    perpage = [perpage, 1].max
    lastpage = ((ct.to_f-1.0) / perpage.to_f).floor.to_i
    if lastpage < 0
      lastpage = 0
    end
    curpage = [curpage.to_i, 0].max
    firstpage = 0
    nextpage = [curpage + 1, lastpage].min
    prevpage = [curpage - 1, firstpage].max

    firstimg = curpage * perpage
    lastimg = firstimg + perpage - 1
    shows = pieces[firstimg..lastimg]
    if shows
      shows.reverse!
    else
      nil
    end
    [ shows, nextpage, prevpage, curpage, lastpage ]
  end

  # def self.fb_share_link(artpiece)
  #   url = artpiece.get_share_link(true)
  #   raw_title = "Check out %s at Mission Artists United" % artpiece.artist.get_name()
  #   title = CGI::escape( raw_title )
  #   "http://www.facebook.com/sharer.php?u=%s&t=%s" % [ url, title ]
  # end

  # def self.tw_share_link(artpiece)
  #   url = artpiece.get_share_link(true)
  #   raw_title = "Check out %s at Mission Artists United" % artpiece.artist.get_name()
  #   status = CGI::escape("%s @sfmau #missionartistsunited " % raw_title)
  #   "http://twitter.com/home?status=%s%s" % [status, url]
  # end
end
