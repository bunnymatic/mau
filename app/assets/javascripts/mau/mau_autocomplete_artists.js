jQuery(function() {
  //artistSuggestFormatter = function(item) { return item.value; }
  var event_artist_list = jQuery('#event_artist_list');
  if (event_artist_list.length) {
    var ajaxParams = {
      url: "/artists/suggest",
      dataType: 'json',
      success: function(data) {
        tags = _.map(data.artists || [], function(item) { return item.value }),
        event_artist_list.select2({
          tags: tags,
          minimumInputLength: 3,
          multiple: true
        });
      }
    };
    jQuery.ajax(ajaxParams);
  }
});
