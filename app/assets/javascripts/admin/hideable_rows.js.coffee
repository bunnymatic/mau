jQuery ->
  # // admin events filtering
  jQuery(".js-hideable-rows.events").hideableRows
    row: ".event"
    whatToHideSelectors: ".filters input"

  jQuery(".show_all").bind "click", ->
    $(this).closest(".filters").find("input").removeAttr "checked"
    return

