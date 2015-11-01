MAU = window.MAU = window.MAU || {}

MAU.Flash = class Flash

  wrapper: 'jsFlash'

  clear: ->
    jQuery(".flash, .flash__notice , ##{@wrapper}").remove();

  show: (options, container) ->
    @clear()
    $w = @construct(options);
    return unless $w
    container ||= '.js-main-container'
    c = jQuery(container).first();
    if (!c.length)
      c = document.body;
    jQuery(c).prepend($w);
    $w.find('.close-btn').bind 'click', (ev) ->
      ev.preventDefault()
      $w.hide()
    setTimeout () ->
      $w.hide()
    ,
      @timeout
    $w.show();

  construct: (options) ->
    @timeout = options.timeout || 10000
    contents = jQuery('<div>')
    $close = jQuery('<i>', {'class':'flash__close fa fa-icon fa-times-circle-o'})
    for k in ['error','notice']
      if (options[k])
        msg = options[k];
        clzs = ["flash"];
        clzs.push "flash__error" if k == 'error'
        clzs.push "flash__notice" if k == 'notice'
        contents.append(jQuery('<div>', {'class': clzs.join(" ")}).html(msg).prepend($close));


    if (contents.html().length)
      $flash = jQuery('<div>', {id:@wrapper})
      $flash.html(contents)
      $flash
    else
      null
