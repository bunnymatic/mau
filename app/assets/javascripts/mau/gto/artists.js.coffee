$ ->

  if $('.artists.show').length
    # add read more button if necessary
    $bio = $('.artist__bio')
    $bio.toggleClass('overflowing', $bio.isOverflowing()) if $bio.length
    $bio.next('.js-read-more').on 'click', (ev) ->
      ev.preventDefault();
      $bio.toggleClass('open')
      $bio.scrollTop(0);
      t = if $bio.hasClass('open') then 'Read Less' else 'Read More'
      $(@).find('span.text').html(t)



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
    getCurrentFilter = () ->
      document.querySelectorAll('.js-filter-by-name')[0].value;

    currentFilter = getCurrentFilter()
    resetSearch = () ->
      $wrapper = $('js-artists-scroll-wrapper')
      currentMode = $wrapper.data('filtering')
      currentFilter = getCurrentFilter()
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
      if currentFilter != getCurrentFilter()
        throttledFilter()
