MAU = window.MAU = window.MAU || {}
# front page thumb sampler

MAU.Sampler = class Sampler

  constructor: (container, refreshTime) ->
    @container = container
    @refreshTime = refreshTime || 100000
    @requests = []

  start: =>
    @updateArt()

  updateArt: =>
    container = $(@container);
    if (container.length)
      ajaxOpts =
        url: '/main/sampler'
        method:'get'
        success: (data, status, xhr) =>
          container.fadeOut =>
            container.html(data).fadeIn()
          setTimeout(@updateArt, @refreshTime);
      jQuery.ajax( ajaxOpts )

if (document.location.pathname == '/')
  sampler = new MAU.Sampler('#sampler')
  jQuery(window).bind('load', sampler.start);
