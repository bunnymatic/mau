#= require dataTables/jquery.dataTables
jQuery ->
  tables = [ "#tags_index.js-data-tables",
             "#mediums_index.js-data-tables",
             "#fans_index.js-data-tables",
             "#artists_index.js-data-tables"].join(', ')
  jQuery(tables).dataTable
    aaSorting: []
    paging: false
    info: false

  
  # // admin events filtering
  jQuery(".js-hideable-rows.events").hideableRows
    row: ".event"
    whatToHideSelectors: ".filters input"

  jQuery(".show_all").bind "click", ->
    $(this).closest(".filters").find("input").removeAttr "checked"
    return

  jQuery("#os_combo_link").bind "click", ->
    $frm = jQuery("#multi_form")
    $frm.slideToggle()
    return

  jQuery(".add_btn").each ->
    jQuery(this).bind "click", (ev) ->
      ev.preventDefault()
      $li = jQuery(this).closest("li")
      if $li.length
        $container = $li.find(".add_email")
        $container.slideToggle()
      false

    return

  jQuery(".del_btn").each ->
    jQuery(this).bind "click", (ev) ->
      $this = jQuery(this)
      ev.preventDefault()
      $li = $this.closest("li")
      $ul = $this.closest("ul")
      if $li and $ul
        email = $li.text().replace(/^\s+|\(x\)|\s+$/g, "")
        email_id = $li.attr("email_id")
        listname = $ul.attr("list_type")
        if email and listname and email_id
          if confirm("Whoa Nelly!  Are you sure you want to remove " + email + " from the " + listname + " list?")
            data_url = "/admin/email_lists/" + email_id
            ajax_data =
              url: data_url
              method: "delete"
              data:
                authenticity_token: unescape(authenticityToken)
                listtype: listname

              success: (data, status, xhr) ->
                $li.remove()
                return

            jQuery.ajax ajax_data
      return

    return

  return
