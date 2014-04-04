jQuery ->

  art_piece_form = document.getElementById('new_artpiece_form')
  if art_piece_form
    submit_button = jQuery(art_piece_form).find('input[type=submit]')
    if submit_button.length
      submit_button.bind 'click', (ev) ->
        ArtPieces = new MAU.ArtPieces()
        if !ArtPieces.validate(art_piece_form)
          MAU.waitcursor()
          true
        else
          ev.preventDefault()
          false
