$ ->
  SEARCH_FORM_ID = 'search_form_container'
  INPUT_SELECTOR = 'input#search_keywords'
  RESULTS_CONTAINER = '.search-autocomplete-results'
  RESULT_ITEM = '.search-autocomplete-result'

  search_spinner = null
  searchHelpers =
    closeSearch: ->
      $(".js-in-page-search.active").removeClass('active')
      $("##{SEARCH_FORM_ID}").removeClass('open')

  startSpinner = ->
   search_spinner = new MAU.Spinner() unless search_spinner
   search_spinner.spin()
  stopSpinner = ->
   search_spinner?.stop()

  currentPage = new MAU.QueryStringParser(location.href)
  onSearchPage = (currentPage.pathname == '/search')

  if onSearchPage
    $('.js-in-page-search').addClass("active")

  buildResultHtml = (result) ->
    type = result._type
    template = new MAU.Template("search_autocomplete_result_#{type}_template");
    data = result['_source'][type]
    data._id = result['_id']
    data.backgroundImage = "background-image: url(#{data.images.thumb});";
    template.html(data)

  search = ->
    startSpinner()
    $.ajax
      url: '/search.json'
      data:
        q: $(INPUT_SELECTOR).val()
        limit: 20
      success: (data) ->
        $(RESULTS_CONTAINER).find('.js-results li').remove()
        _.each (data.search || data), (result) ->
          entry = buildResultHtml(result)
          $(RESULTS_CONTAINER).find('.js-results').append(entry)
      error: (data) ->
      complete: () ->
        stopSpinner()

  throttledSearch = MAU.Utils.debounce(search, 150, true)

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
      getResultItems().first().addClass('selected')

  selectPrevious = ->
    selected = getSelected()
    if selected
      previous = selected.prev(RESULT_ITEM)
      getResultItems().removeClass('selected')
      previous.addClass('selected')
    else
      getResultItems().first().addClass('selected')

  gotoSelected = (ev)->
    selected = getSelected()
    if selected
      ev.preventDefault()
      location.href = $(selected).find('a').attr('href')
      false

  $('.js-main-container').on 'keyup change', INPUT_SELECTOR, (ev) ->
    # console.log 'keyup or change'
    # console.log ev.which
    # 40 = arrow down
    # 38 = arrow up
    # 27 = esc
    switch ev.which
      when 27
        searchHelpers.closeSearch()
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
