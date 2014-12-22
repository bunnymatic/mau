$ ->
  SEARCH_FORM_ID = 'search_form_container'
  INPUT_SELECTOR = 'input#search_keywords'
  RESULTS_CONTAINER = '.search-autocomplete-results'  
  RESULT_ITEM = '.search-autocomplete-result'  
  $('.nav-icon.search').on 'click', (ev) ->
    unless $("##{SEARCH_FORM_ID}").length
      template = new MAU.Template('search_form_template')
      $("##{SEARCH_FORM_ID}").remove()
      $('.js-main-container').append($(template.html()).attr("id", SEARCH_FORM_ID))
    $("##{SEARCH_FORM_ID}").toggleClass('open').find(INPUT_SELECTOR).focus()

  buildArtPieceHtml = (art_piece) ->
    template = new MAU.Template('search_autocomplete_result_template')
    template.html(art_piece)

  search = ->
    console.log 'search'
    $.ajax
      url: '/search/fetch.json'
      data:
        keywords: $(INPUT_SELECTOR).val()
        limit: 20
      success: (data) ->
        $(RESULTS_CONTAINER).find('.js-results li').remove()
        _.each data, (art_piece) ->
          entry = buildArtPieceHtml(art_piece)
          $(RESULTS_CONTAINER).find('.js-results').append(entry)
      error: (data) ->
        
  throttledSearch = MAU.Utils.debounce(search,150,false)

  selectNext = ->
    $results = $(RESULTS_CONTAINER)
    selected = $results.find(".selected")
    if selected.length
      console.log 'next selected'
      next = selected.next(RESULT_ITEM)
      $results.find(RESULT_ITEM).removeClass('selected')
      next.addClass('selected')
    else
      console.log 'add selected'
      $results.find(RESULT_ITEM).first().addClass('selected')  

  selectPrevious = ->
    selected = $(RESULTS_CONTAINER).find(".selected")
    console.log(selected)

    
  $('.js-main-container').on 'keyup change', INPUT_SELECTOR, (ev) ->
    console.log 'keypress'
    console.log ev.which
    # 40 = arrow down
    # 38 = arrow up
    switch ev.which
      when 40
        selectNext()
      when 38
        selectPrevious()
    throttledSearch()
    

  $('.js-main-container').on 'submit', "##{SEARCH_FORM_ID} form", (ev) ->
    unless $(INPUT_SELECTOR).val()
      $("##{SEARCH_FORM_ID}").removeClass('open')
      ev.preventDefault()
      false
      

