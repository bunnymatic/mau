jQuery(function() {
  if (jQuery('#map-canvas').length && MAU.map_markers) {
    handler = Gmaps.build('Google');
    handler.buildMap({ provider: {}, internal: {id: 'map-canvas'}}, function(){
      markers = handler.addMarkers(_.compact(MAU.map_markers));
      handler.bounds.extendWith(markers); 
      handler.fitMapToBounds();
  });
  }

  /** handle os switch on map page */
  jQuery('#map_cb').bind('click', function(ev) {
    ev.stopPropagation();
    jQuery('#map_osswitcher').submit();
  });

});


