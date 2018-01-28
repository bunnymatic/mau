MAU = window.MAU = window.MAU || {}

class Flash

  wrapper: 'jsFlash'

  clear: ->
    _.map(document.querySelectorAll(".flash, .flash__notice , ##{@wrapper}"), (el) ->
      el.parentNode.removeChild(el) if el
    )
  show: (options, container) ->
    @clear()
    $w = @construct(options);
    return unless $w
    container ||= 'body, .js-main-container'
    c = jQuery(container).first();
    if (!c.length)
      c = document.body;
    jQuery(c).prepend($w);
    $w.find('.flash__close').bind 'click', (ev) ->
      ev.preventDefault()
      $w.hide()
    if @timeout
      setTimeout () ->
        $w.hide()
      ,
        @timeout
    $w.show();

  construct: (options) ->
    if options.timeout < 0
      @timeout = null
    else
      @timeout = options.timeout || 10000
    contents = jQuery('<div>')
    $close = jQuery('<i>', {'class':'flash__close fa fa-icon fa-times-circle-o'})

    key = _.intersection(_.keys(options), ["error", "notice"])[0]

    if (options[key])
      msg = options[key];
      clz ="flash flash__" + key

      contents = jQuery('<div>', {'class': clz}).html(msg).prepend($close)

    if (contents.html().length)
      $flash = jQuery('<div>', {id:@wrapper})
      $flash.html(contents)
      $flash
    else
      null

MAU.Flash = Flash
