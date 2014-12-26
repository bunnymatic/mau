$ ->
  if $('.artists.index').length
    $win = $(window)
    $win.scroll ->
      if $win.scrollTop() == ($(document).height() - $win.height())
        $more = $('#js-scroll-load-more')
        if $more.length
          $content = $('.js-artists-scroll-wrapper')
          page = parseInt($more.data('page') || 0,10);
          nextPage = page + 1
          $more.fadeIn()
          $.ajax
            url: "/artists?p=" + nextPage
            success: (data) ->
              $more.data('page', nextPage)
              if data
                $content.append(data);
                $more.fadeOut();
              else
                $content.append($("<div class='pure-g-1-1'><h2>done</h2></div>"))
                $more.remove()

  $('.tabs').tab();
