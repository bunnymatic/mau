jQuery ->
  return unless jQuery.fn.dataTable

  tables = "body.admin .js-data-tables"

  config =
    artists_index:
      order: [[ 3, "desc" ]]

  isSearchableTable = (_idx, el) ->
    !$(el).hasClass('js-data-tables-no-search')

  isNotSearchableTable = (_idx, el) ->
    !isSearchableTable(_idx, el)

  jQuery(tables).filter(isSearchableTable).each ->
    $table = jQuery(this)
    opts = _.extend {}, { aaSorting: [], paging: false, info: false }, config[$table.attr('id')]

    jQuery($table).dataTable opts

  jQuery(tables).filter(isNotSearchableTable).each ->
    $table = jQuery(this)
    opts = _.extend {}, { aaSorting: [], paging: false, info: false, searching: false }, config[$table.attr('id')]

    jQuery($table).dataTable opts
