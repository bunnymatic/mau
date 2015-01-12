$ ->
  if $('.artists.index').length

    fetchArtists = (ev) ->
      $more = $('#js-scroll-load-more')
      $spinner = $more.find('.fa-spinner')
      filter = $('.js-filter-by-name').val()
      if $more.length
        $content = $('.js-artists-scroll-wrapper')
        page = parseInt($more.data('page') || 0,10);
        nextPage = page + 1
        $spinner.fadeIn()
        $.ajax
          url: "/artists"
          data:
            p: nextPage
            filter: filter
          success: (data) ->
            $more.data('page', nextPage)
            if data
              $content.append(data);
              $more.fadeOut();
            else
              $more.remove()
      
    $win = $(window)
    $win.scroll ->
      if $win.scrollTop() == ($(document).height() - $win.height())
        fetchArtists()

   
  fetchFilteredArtist = () ->
    $more = $('#js-scroll-load-more')
    filter = $('.js-filter-by-name').val()
    $.ajax
      url: "/artists"
      data:
        p: 1
        filter: filter
        success: (data) ->
          $content = $('.js-artists-scroll-wrapper')
          $('.artist-card').remove();
          $more.data('page', 2)
          if data
            $content.append(data);
          else
            $more.remove()
  throttledFilter = MAU.Utils.debounce(fetchFilteredArtist,150,false)
  
  $("#js-artist-index-filter .js-filter-by-name").on 'keydown change', (ev) ->
    throttledFilter()

