$ ->
  SEARCH_FORM_ID = 'search_form_container'
  INPUT_SELECTOR = 'input#search_keywords'
  
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
        $('.search-autocomplete-results').find('.js-results li').remove()
        _.each data, (art_piece) ->
          entry = buildArtPieceHtml(art_piece)
          $('.search-autocomplete-results .js-results').append(entry)
      error: (data) ->
        
  throttledSearch = MAU.Utils.debounce(search,150,false)

  $('.js-main-container').on 'keyup change', INPUT_SELECTOR, () ->
    console.log 'got key press or change',
    throttledSearch()
    

  $('.js-main-container').on 'submit', "##{SEARCH_FORM_ID} form", (ev) ->
    unless $(INPUT_SELECTOR).val()
      $("##{SEARCH_FORM_ID}").removeClass('open')
      ev.preventDefault()
      false
      

