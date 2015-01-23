$ ->

  if $('.artists.show').length
    # add read more button if necessary
    $bio = $('.artist__bio')
    $bioText = $bio.find(".bio-container")
    $bio.toggleClass('overflowing', $bioText.isOverflowing()) if $bio.length
    $bio.on 'click', '.read-more', (ev) ->
      ev.preventDefault();
      $bio.toggleClass('open')
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


