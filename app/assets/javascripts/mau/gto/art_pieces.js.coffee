$ ->
  # on art pieces edit page
  $artPieceForm = jQuery('.art_piece.formtastic')
  if ($artPieceForm.length)
    $('#art_piece_medium_id').select2();

    $('input[type=submit]').on 'click', ->
      if (/add/i).test($(@).val())
        spinner = new MAU.Spinner()
        spinner.spin()


    jQuery.ajax
      url: '/art_piece_tags/autosuggest'
      type: 'post'
      dataType: "json"
      success: (data) ->
        $("#art_piece_tag_ids").select2(
          tags: data
          tokenSeparators: ["," ]
          minimumInputLength: 3
          multiple: true
        )
