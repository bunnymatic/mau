$ ->
  if $('.studios.index').length
    currentFilter = $('.js-filter-by-name').val();

    fetchFilteredStudios = (ev) ->
      filter = $('.js-filter-by-name').val().trim()
      if filter
        filters = filter.split /\s+/
        regexs = _.map(filters, (filter) -> new RegExp(filter, 'i'))
        $('.studio-card').each () ->
          studio = $(this)
          show = _.any regexs, (regex) -> regex.test studio.data('name') 
          if show && !studio.is(':visible')
            studio.fadeIn()
          else if !show && studio.is(':visible')
            studio.fadeOut()
      else
        $('.studio-card').fadeIn();

    throttledFilter = MAU.Utils.debounce(fetchFilteredStudios,250,false)
    
    $("#js-studio-index-filter .js-filter-by-name").on 'keyup change', (ev) ->
      throttledFilter()
