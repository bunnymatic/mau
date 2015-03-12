$ ->
  SEARCH_FORM_ID = 'search_form_container'
  INPUT_SELECTOR = 'input#search_keywords'
  RESULTS_CONTAINER = '.search-autocomplete-results'
  RESULT_ITEM = '.search-autocomplete-result'

  searchHelpers =
    closeSearch: ->
      $(".sidenav .search.active").removeClass('active')
      $("##{SEARCH_FORM_ID}").removeClass('open')

  $('.nav-icon.search').on 'click', (ev) ->
    ev.preventDefault()
    unless $("##{SEARCH_FORM_ID}").length
      template = new MAU.Template('search_form_template')
      $("##{SEARCH_FORM_ID}").remove()
      $('.js-main-container').append($(template.html()).attr("id", SEARCH_FORM_ID))
    $searchForm = $("##{SEARCH_FORM_ID}")
    opening = !$(@).hasClass('active')
    if opening
      MAU.Navigation.hideTabs()
    $(@).toggleClass('active', opening)
    $searchForm.toggleClass('open', opening).find(INPUT_SELECTOR).focus()


  buildArtPieceHtml = (art_piece) ->
    template = new MAU.Template('search_autocomplete_result_template')
    template.html(art_piece)

  search = ->
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

  getSelected = ->
    selected = $(RESULTS_CONTAINER).find(".selected")
    if selected.length then selected else null

  getResultItems = ->
    $(RESULTS_CONTAINER).find(RESULT_ITEM)

  selectNext = ->
    selected = getSelected()
    if selected
      next = selected.next(RESULT_ITEM)
      getResultItems().removeClass('selected')
      next.addClass('selected')
    else
      console.log 'add selected'
      getResultItems().first().addClass('selected')

  selectPrevious = ->
    selected = getSelected()
    if selected
      console.log 'next selected'
      previous = selected.prev(RESULT_ITEM)
      getResultItems().removeClass('selected')
      previous.addClass('selected')
    else
      console.log 'add selected'
      getResultItems().first().addClass('selected')

  gotoSelected = (ev)->
    selected = getSelected()
    if selected
      ev.preventDefault()
      location.href = $(selected).find('a').attr('href')
      false

  $('.js-main-container').on 'keyup change', INPUT_SELECTOR, (ev) ->
    console.log 'keyup or change'
    console.log ev.which
    # 40 = arrow down
    # 38 = arrow up
    switch ev.which
      when 40
        selectNext()
      when 38
        selectPrevious()
      when 13
        gotoSelected(ev)
      else
        throttledSearch()


  $('.js-main-container').on 'submit', "##{SEARCH_FORM_ID} form", (ev) ->
    unless $(INPUT_SELECTOR).val()
      searchHelpers.closeSearch()
      ev.preventDefault()
      false

  window.MAU ||= {}
  MAU.Search ||= {}
  MAU.Search = _.extend({}, MAU.Search, searchHelpers);
