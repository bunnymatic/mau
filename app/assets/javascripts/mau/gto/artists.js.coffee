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


  if $('.artists.index, .open_studios.show').length
    fetching = false

    fetchArtists = (url) ->
      return if fetching
      fetching = true
      $content = $('.js-artists-scroll-wrapper')
      pagination = $('.js-pagination-state').last().data()
      if pagination.hasOwnProperty('hasMore')
        nextPage = pagination.nextPage
        $.ajax(
          url: url
          data:
            s: pagination.sortOrder
            l: pagination.currentLetter
            p: nextPage
            os_only: pagination.osOnly
        ).done (data) ->
          # remove the current more button
          $('#js-scroll-load-more').remove();
          if data
            $content = $('.js-artists-scroll-wrapper')
            $content.append(data);
          fetching = false

    url = if ($('.artists.index')[0]?) then "/artists" else "/open_studios"
    # set event bindings
    $win = $(window)
    $win.scroll ->
      if $win.scrollTop() == ($(document).height() - $win.height())
        fetchArtists(url)
    # if the scroll div top is in the window, fetch another set

    $more = $('#js-scroll-load-more');
    if ($more.length) && ($more.position().top < $win.height())
      fetchArtists(url)
