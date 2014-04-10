jQuery.fn.focusFirst = () ->
  this.each () =>
    this.find('input').not('[type=hidden]').first().focus()
