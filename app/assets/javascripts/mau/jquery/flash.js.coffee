MAU = window.MAU = window.MAU || {}

MAU.Flash = class Flash

  wrapper: 'jsFlash'

  clear: ->
    jQuery('#' + @wrapper).remove();
    
  show: (msgs, container) ->
    @clear()
    $w = @construct(msgs);
    return unless $w
    c = jQuery(container).first();
    if (!c.length)
      c = document.body;
    jQuery(c).prepend($w);
    $w.find('.close-btn').bind 'click', () ->
 	    $w.hide()
    setTimeout () ->
      $w.hide()
    ,
      10000
    $w.show();

  construct: (msgs) ->
    err = msgs.error
    notice = msgs.notice
    contents = jQuery('<div>')
    $close = jQuery('<div>', {'class':'close-btn'}).html('x')
    for k in ['error','notice']
      if (msgs[k]) 
        msg = msgs[k];
        clz = k;
        clz = 'error-msg' if k == 'error'
        contents.append(jQuery('<div>', {'class': clz}).html(msg).prepend($close));

        
    if (contents.html().length)
      $flash = jQuery('<div>', {id:@wrapper})
      $flash.html(contents)
      $flash
    else
      null
