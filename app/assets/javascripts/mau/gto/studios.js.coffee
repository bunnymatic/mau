$ ->
  if $('.studios.index').length

    fetchFilteredStudios = (ev) ->
      filter = document.querySelectorAll('.js-filter-by-name')[0].value;
      if filter
        filters = _.uniq(_.compact(filter.split /\s+/))
        regexs = _.map(filters, (filter) -> new RegExp(filter, 'i'))
        $('.studio-card').each () ->
          studio = $(this)
          show = _.some
          ny regexs, (regex) -> regex.test studio.data('name')
          if show && !studio.is(':visible')
            studio.fadeIn()
          else if !show && studio.is(':visible')
            studio.fadeOut()
      else
        $('.studio-card').fadeIn();

    throttledFilter = MAU.Utils.debounce(fetchFilteredStudios,250,false)

    $("#js-studio-index-filter .js-filter-by-name").on 'keyup change', (ev) ->
      throttledFilter()
    $("#js-studio-index-filter").on 'submit', (ev) -> ev.stopPropagation(); false
