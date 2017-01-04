$ ->
  # on art pieces edit page
  $artPieceForm = jQuery('.art_piece.formtastic')
  if ($artPieceForm.length)
    $('#art_piece_medium_id').selectize();

    $('input[type=submit]').on 'click', ->
      if (/add/i).test($(@).val())
        spinner = new MAU.Spinner()
        spinner.spin()

    $('#art_piece_tag_ids').selectize(
      delimiter: ','
      persist: false
      sortField: 'text'
      create: (input) -> { value: input, text: input }
      render: (data, escape) ->
        data
      load: (query, callback) ->
        if (query.length < 3)
           callback();
        $.ajax
          url: '/art_piece_tags/autosuggest'
          type: 'post'
          dataType: "json"
          data:
            q: query,
          error: () ->
            callback();
          success: (results) ->
            console.log('fetched ', results)
            callback(_.map(results, (result) -> { value: result, text: result } ))
    )
