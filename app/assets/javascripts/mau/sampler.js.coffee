$ ->
  NUM_IMAGES = 12
  fetchArtists = (ev) ->
    $content = $('.js-sampler')
    return unless $content.find('#js-scroll-load-more').length
    seed = $content.data('seed');
    offset = $content.data('offset') || 0;
    $.ajax(
      method: 'post'
      url: '/main/sampler'
      data:
        seed: seed
        offset: offset
        number_of_images: NUM_IMAGES
    ).done (data) ->
      if data && !/^\s+$/.test(data)
        $insertion = $content.find('#js-scroll-load-more')
        $(data).insertBefore($insertion);
        $content.data('offset', 0 + offset + NUM_IMAGES);
        $more = $('#js-scroll-load-more');
        # if the scroll div top is in the window, fetch another set
        if ($more.length) && ($more.position().top < $win.height())
          fetchArtists()
      else
        # remove the current more button
        $('#js-scroll-load-more').remove()
        $('#the-end').show()
        
  if $('#sampler').length
    $win = $(window)
    $win.scroll ->
      if $win.scrollTop() == ($(document).height() - $win.height())
        fetchArtists()
    fetchArtists()

