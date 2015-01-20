$ ->

  # hits both studio and artist pages
  $('.js-filter-visibility').on 'click', '.fa-search', () ->
    # suppress submit
    $(@).closest('form').on 'submit', -> false
    input = $(@).closest('div').find('input')
    input.focus()
    
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


