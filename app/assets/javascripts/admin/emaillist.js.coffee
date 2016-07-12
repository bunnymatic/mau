jQuery ->
  jQuery(".js-os-combo-link").on "click", (ev) ->
    ev.preventDefault()
    $frm = jQuery(".js-multi-form")
    $frm.slideToggle()
    false
