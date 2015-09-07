jQuery ->
  return unless jQuery.fn.dataTable


  tables = [ "#tags_index.js-data-tables",
             "#cms_contents_index.js-data-tables",
             "#os_status_table.js-data-tables",
             '#favorites_index.js-data-tables',
             "#mediums_index.js-data-tables",
             "#fans_index.js-data-tables",
             '#artist_feeds_index.js-data-tables',
             '#studios_index.js-data-tables',
             "#artists_index.js-data-tables"].join(', ')

  config =
    artists_index:
      order: [[ 3, "desc" ]]

  jQuery(tables).each () ->
    $table = jQuery(this)
    opts = _.extend {}, { aaSorting: [], paging: false, info: false }, config[$table.attr('id')]

    jQuery($table).dataTable opts
