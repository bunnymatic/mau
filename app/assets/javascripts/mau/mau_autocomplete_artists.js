jQuery(function() {
  artistSuggestFormatter = function(item) { return item.value; }
  jQuery('#event_artist_list').select2({
    multiple: true,
    placeholder: "find artists by name",
    minimumInputLength: 3,
    ajax: { // instead of writing the function to execute the request we use Select2's convenient helper
      url: "/artists/suggest",
      dataType: 'json',
      data: function (query, result) {
        return {
          q: query, // search term
          page_limit: 10,
        };
      },
      results: function (data, result) { // parse the results into the format expected by Select2.
        // since we are using custom formatting functions we do not need to alter remote JSON data
        return {results: data}
      }
    },
    formatResult: artistSuggestFormatter,
    formatSelection: artistSuggestFormatter
  });
});
