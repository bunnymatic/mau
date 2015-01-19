MAU = window.MAU = window.MAU || {}
# front page thumb sampler

MAU.Sampler = class Sampler

  constructor: (container, refreshTime) ->
    @container = container
    @refreshTime = refreshTime || 60000
    @fadeTime = 400
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
          existing = container.find('a[class^=pure-u]')
          $('.sampler__empty').remove();
          if existing.length
            existing.fadeOut duration: @fadeTime
            setTimeout ->
              container.find('.sampler__promo').after(data);
            , @fadeTime
          else
            container.find('.sampler__promo').after(data);
          setTimeout(@updateArt, @refreshTime);
      jQuery.ajax( ajaxOpts )

if (document.location.pathname == '/')
  sampler = new MAU.Sampler '#sampler.js-sampler'
  jQuery(window).bind 'load', sampler.start
