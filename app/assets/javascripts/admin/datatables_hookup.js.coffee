jQuery ->
  tables = [ "#tags_index.js-data-tables",
             "#cms_contents_index.js-data-tables",
             "#os_status_table.js-data-tables",
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
