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
        console.log('rendering ', data)
        data
      load: (query, callback) ->
        if (!query.length)
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

    # $("#art_piece_tag_ids").select2
    #   tokenSeparators: ["," ]
    #   minimumInputLength: 3
    #   multiple: true
    #   ajax:
    #     url: '/art_piece_tags/autosuggest'
    #     type: 'post'
    #     dataType: "json"
    #     data: (params) ->
    #       {
    #         q: params.term
    #         page: 1
    #       }
    #     processResults: (data, params) ->
    #       {
    #         results: _.map(data, (tag) -> {id: tag, text: tag})
    #         pagination: { }
    #       }
    #   tokenSeparators: ["," ]
    #   minimumInputLength: 3
    #   multiple: true
    #   tags: true
    #   width: '90%'
