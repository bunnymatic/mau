#= require dataTables/jquery.dataTables
jQuery ->
  tables = [ "#tags_index.js-data-tables",
             '#favorites_index.js-data-tables',
             "#mediums_index.js-data-tables",
             "#fans_index.js-data-tables",
             '#artist_feeds_index.js-data-tables',
             '#studios_index.js-data-tables',
             "#artists_index.js-data-tables"].join(', ')
  jQuery(tables).dataTable
    aaSorting: []
    paging: false
    info: false
