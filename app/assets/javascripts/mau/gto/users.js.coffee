$ ->
  # user edit accordion stuff
  if location.hash && (location.hash.length > 1) # don't switch on just #
    # accordion automatically opens this one, but we need to remove the collapsed class
    $(location.hash).collapse('show');
  $('.toggle-button input[type=checkbox]').on 'change', (ev) ->
    val = $(this).is(':checked')
    (new MAU.Flash()).clear()
    form = jQuery('.js-edit-artist-form')
    ajax_params =
      url: form.attr('action')
      method: form.attr('method')
      data:
        artist:
          os_participation: (if val then 1 else 0)
      success: (data) ->
        status = data.success && data.os_status
        flash = new MAU.Flash()
        flash.clear()

        if !status
          msg = 'So sorry you\'re not going to participate this year.'+
            ' We\'d love to know why.  Tell us via the feedback link'+
            ' at the bottom of the page.'
        else
          msg = 'Super!  The more the merrier!'
        flash.show({notice:msg}, '#events')
        false
    jQuery.ajax(ajax_params)
    false
    
