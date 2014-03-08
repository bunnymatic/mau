MAU = window.MAU = window.MAU || {}
# front page thumb sampler

MAU.Sampler = class Sampler

  constructor: (refreshTime) ->
    @refreshTime = refreshTime || 10000
    @requests = []

  start: =>
    setInterval( @updateArt, @refreshTime);

  updateArt: =>
    samplerDom = jQuery('#sampler')
    if (samplerDom.length)
      ajaxOpts =
        url: '/main/sampler'
        method:'get'
        success: (data, status, xhr) ->
          samplerDom.fadeOut ->
            samplerDom.html(data)
            samplerDom.fadeIn()
      request = jQuery.ajax( ajaxOpts )
      @requests.push(request);

  abortRequests: () ->
    for req in @requests
      req.abort() if req.abort
    @requests = []

if (document.location.pathname == '/')
  sampler = new MAU.Sampler()
  jQuery(window).bind('load', sampler.start);
  jQuery(window).bind('unload', sampler.abortRequests);
