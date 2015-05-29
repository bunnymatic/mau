$.fn.isOverflowing = ->
  el = $(@)[0]
  (el.scrollHeight > el.offsetHeight) || (el.scrollWidth > el.offsetWidth)
