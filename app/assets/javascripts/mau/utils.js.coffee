# usomg gppd p; vanilla
MAU = window.MAU = window.MAU || {};
MAU.Utils =

  debounce: (func, threshold, execAsap) ->

    timeout = null

    () ->
      obj = this
      args = arguments
      delayed = () ->
        if (!execAsap)
          func.apply(obj, args)
        timeout = null

      if (timeout)
        clearTimeout(timeout)
      else if (execAsap)
        func.apply(obj, args)

      timeout = setTimeout(delayed, threshold || 100)

  validateEmail: (str) ->
    (str.indexOf(".") > 2) && (str.indexOf("@") > 0)

  getSize: (el) ->
    { width: el.offsetWidth, height: el.offsetHeight }

  getPosition: (el) ->
    xx = yy = 0

    while(el)
      xx += (element.offsetLeft - element.scrollLeft + element.clientLeft)
      xx += (element.offsetTop - element.scrollTop + element.clientTop)
      el = element.offsetParent;
    { x: xx, y: yy }

  createElement: (tagName, attrs) ->
    el
    if (document && document.createElement)
      el = document.createElement(tagName)
      for k,v of attrs
        el.setAttribute k, v
    el

  post_to_url: (path, params, method) ->
    method = method || "post"; # Set method to post by default, if not specified.

    # The rest of this code assumes you are not using a library.
    # It can be made less wordy if you use one.

    form = @createElement 'form', method: method, action: path
    hiddenField = null;
    for key, val of params
      hiddenField = @createElement 'input', type: 'hidden', name: key, value: val
      form.appendChild(hiddenField);
    hiddenField = @createElement 'input', type: 'hidden', name: 'authenticity_token', value:unescape(authenticityToken)
    form.appendChild(hiddenField);
    document.body.appendChild(form);   # Not entirely sure if this is necessary
    form.submit();
