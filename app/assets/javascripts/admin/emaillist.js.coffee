jQuery ->
  jQuery("#os_combo_link").bind "click", ->
    $frm = jQuery("#multi_form")
    $frm.slideToggle()

  jQuery(".add_btn").each ->
    jQuery(this).bind "click", (ev) ->
      ev.preventDefault()
      $li = jQuery(this).closest("li")
      if $li.length
        $container = $li.find(".add_email")
        $container.slideToggle().toggleClass('open')
      false

  jQuery(".del_btn").each ->
    jQuery(this).bind "click", (ev) ->
      $this = jQuery(this)
      $href = $this.attr('href')
      ev.preventDefault()
      
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
