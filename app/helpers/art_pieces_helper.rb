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
    ct = pieces.length
    lastpage = ((ct.to_f-1.0) / perpage.to_f).floor.to_i
    curpage = curpage.to_i
    firstpage = 0
    nextpage = [curpage + 1, lastpage].min
    prevpage = [curpage - 1, firstpage].max 
    
    firstimg = curpage * perpage
    lastimg = firstimg + perpage - 1
    shows = pieces[firstimg..lastimg]
    if shows
      shows.reverse!
    end
    [ shows, nextpage, prevpage, curpage, lastpage ]
  end

  # compute real image size given piece (which has wd/ht) and
  # size (string) indicating what we're drawing
  # return wd, ht
  def compute_actual_image_size(size, piece)
    k = eval(':' + size)
    sz = ImageFile.sizes[k]
    if !sz
      return 0,0
    end
    maxdim = sz.values.max
    wd = ht = 0
    if piece.image_width > 0 and piece.image_height > 0
      rt = piece.image_height.to_f / piece.image_width.to_f
      if rt < 1.0
        wd = maxdim.to_i
        ht = (wd * rt).to_i
      else
        ht = maxdim.to_i
        wd = (ht / rt).to_i
      end
    end
    return wd,ht
  end
end
