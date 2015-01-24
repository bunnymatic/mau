$ ->

  if $('.artists.show').length
    # add read more button if necessary
    $bio = $('.artist__bio')
    $bioText = $bio.find(".bio-container")
    $bio.toggleClass('overflowing', $bioText.isOverflowing()) if $bio.length
    $bio.on 'click', '.read-more', (ev) ->
      ev.preventDefault();
      $bio.toggleClass('open')

    # hide artists details column
    $('#js-hide-artist-details').on 'click', (ev) ->
      $left = $('#about')
      $right = $('#art')
      $columns = $left.find('.artist-profile[class^=pure-u-]')
      $columns.first().toggleClass('pure-u-lg-1-2')
      $columns.last().toggleClass('collapsed pure-u-lg-1-2')
      $left.toggleClass('pure-u-md-1-2 pure-u-md-1-3 pure-u-lg-1-5 pure-u-lg-2-5')
      $right.toggleClass('pure-u-md-1-2 pure-u-md-2-3 pure-u-lg-4-5 pure-u-lg-3-5')
      btnText = $(@).html()
      if (/hide/i).test btnText
        btnText = btnText.replace('Hide', 'Show')
      else
        btnText = btnText.replace('Show', 'Hide')
      $(@).html(btnText)


  if $('.artists.index').length
    # define helpers
    currentFilter = $('.js-filter-by-name').val();

    resetSearch = () ->
      $wrapper = $('js-artists-scroll-wrapper')
      currentMode = $wrapper.data('filtering')
      currentFilter = $('.js-filter-by-name').val()
      newMode = !!currentFilter
      $wrapper.data('filtering', newMode )
      if newMode != currentMode
        $('.js-pagination-state').slice(1,-1).remove()
        pagination = $('.js-pagination-state').last()
        $('.artist-card').fadeOut duration: 50, complete: -> $(@).remove()
        pagination.data('current_page',0)
        pagination.data('next_page',0)
        pagination.data('has_more',true)

    fetchArtists = (ev) ->
      $content = $('.js-artists-scroll-wrapper')
      pagination = $('.js-pagination-state').last().data()
      if pagination.has_more?
        filter = $('.js-filter-by-name').val()
        nextPage = pagination.next_page
        $.ajax(
          url: "/artists"
          data:
            p: nextPage
            filter: filter
        ).done (data) ->
          # remove the current more button
          $('#js-scroll-load-more').remove();
          if data
            $content = $('.js-artists-scroll-wrapper')
            $content.append(data);

    fetchFilteredArtists = (ev) ->
      resetSearch(ev)
      fetchArtists(ev)

    throttledFilter = MAU.Utils.debounce(fetchFilteredArtists,250,false)

    # set event bindings
    $win = $(window)
    $win.scroll ->
      if $win.scrollTop() == ($(document).height() - $win.height())
        fetchArtists()

    $("#js-artist-index-filter .js-filter-by-name").on 'keyup change', (ev) ->
      if currentFilter != $('.js-filter-by-name').val()
        throttledFilter()
