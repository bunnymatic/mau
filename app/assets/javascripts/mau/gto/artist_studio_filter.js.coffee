$ ->
  # hits both studio and artist pages
  $('.js-filter-visibility').on 'click', '.fa-search', () ->
    # suppress submit
    $(@).closest('form').on 'submit', -> false
    input = $(@).closest('div').find('input')
    input.focus()
    
