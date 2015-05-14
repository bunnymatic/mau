jQuery ->
  jQuery("#os_combo_link").bind "click", ->
    $frm = jQuery("#multi_form")
    $frm.slideToggle()

