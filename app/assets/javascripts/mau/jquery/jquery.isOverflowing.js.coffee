$.fn.isOverflowing = ->
  el = $(this)[0]
  (el.scrollHeight > el.offsetHeight) || (el.scrollWidth > el.offsetWidth)
