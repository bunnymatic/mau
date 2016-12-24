$ ->
  # on art pieces edit page
  $artPieceForm = jQuery('.art_piece.formtastic')
  if ($artPieceForm.length)
    $('#art_piece_medium_id').select2();

    $('input[type=submit]').on 'click', ->
      if (/add/i).test($(@).val())
        spinner = new MAU.Spinner()
        spinner.spin()


    $("#art_piece_tag_ids").select2(
      tags: data
      tokenSeparators: ["," ]
      minimumInputLength: 3
      multiple: true
      ajax:
        url: '/art_piece_tags/autosuggest'
        type: 'post'
        dataType: "json"
        data: (data) ->
          {
            q: data.term
            page: params.page
          }
        processResults: (data, params) ->
          {
            results: data
            pagination: { }
          }
      tokenSeparators: ["," ]
      minimumInputLength: 3
      multiple: true
