$ ->
  fetchArtists = (ev) ->
    $content = $('.js-sampler')
    # set event bindings
    seed = $content.data('seed');
    offset = $content.data('offset');
    $.ajax(
      method: 'post'
      url: '/sampler'
      data:
        seed: seed
        offset: offset
    ).done (data) ->
      # remove the current more button
      # $('#js-scroll-load-more').remove();
      if data
        $content = $('.js-artists-scroll-wrapper')
        $content.append(data);
        $content.data('offset', 0 + $content.data('offset') + 20);
        
  if $('#sampler').length
    $win = $(window)
    $win.scroll ->
      console.log($win.scrollTop(), $(document).height(), $win.height())
      if $win.scrollTop() == ($(document).height() - $win.height())
        fetchArtists()
    # if the scroll div top is in the window, fetch another set

    $more = $('#js-scroll-load-more');
    if ($more.length) && ($more.position().top < $win.height())
      fetchArtists()

