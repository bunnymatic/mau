MAUFEEDS = window.MAUFEEDS || {};

jQuery ->
  # this get's called once with each page load
  # the endpoint only updates the cached filesystem version if it needs update
  MAUFEEDS.requests = []
  MAUFEEDS.freshen_cache = () ->
    $feed_div = jQuery('#feed_div')
    if $feed_div.length
      url = document.location.href
      ajax_attrs =
        url: '/feeds/feed'
        data:
          numentries:1
          page:url
        success: (data,status,xhr) -> {}
      req = jQuery.ajax ajax_attrs
      MAUFEEDS.requests.push( req )

  MAUFEEDS.abort_requests = () ->
    MAUFEEDS.requests.each (req) ->
      req.abort() if req.abort
      MAUFEEDS.requests = [];

  MAUFEEDS.freshen_cache()

  jQuery(document).bind 'beforeunload', () ->
    MAUFEEDS.abort_requests
