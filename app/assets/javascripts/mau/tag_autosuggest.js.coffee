jQuery ->
  $("#tags").select2
    tags: true
    tokenSeparators: [
      ","
      " "
    ]
    createSearchChoice: (term, data) ->
      console.log('csearch', term, data)
      if jQuery(data).filter(->
        term.localeCompare(term) is 0
      ).length is 0
        id: term
        text: term
    minimumInputLength: 3,
    multiple: true
    quietMillis: 100,      
    ajax:
      url: '/art_piece_tags/autosuggest'
      type: 'post'
      dataType: "json"
      data: (term, page) ->
        {q: term}

      results: (data, page) ->
        results: _.map(data, (match) -> {text: match} )
        more: false

  
