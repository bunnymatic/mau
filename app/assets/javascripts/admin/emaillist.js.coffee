jQuery ->
  return unless $('.os_combos')

  jQuery(".js-os-combo-link").bind "click", ->
    $frm = jQuery(".js-multi-form")
    $frm.slideToggle()

