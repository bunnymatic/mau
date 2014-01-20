jQuery(function() {
  if (jQuery('#map-canvas').length && MAU.map_markers) {
    handler = Gmaps.build('Google');
    handler.buildMap({ provider: {}, internal: {id: 'map-canvas'}}, function(){
      markers = handler.addMarkers(MAU.map_markers);
      handler.bounds.extendWith(markers);
      handler.fitMapToBounds();
    });
  }
});
