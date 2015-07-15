$ ->
  if $('#map-canvas').length && MAU.map_markers
    handler = Gmaps.build('Google');
    handler.setOptions
      markers:
        maxRandomDistance: 8
        clusterer:
          maxZoom: 17
          gridSize: 20
    handler.buildMap({
      provider: {},
      internal:
        id: 'map-canvas'
    }, () ->
      markers = handler.addMarkers(_.compact(MAU.map_markers));
      handler.bounds.extendWith(markers);
      handler.fitMapToBounds();
    )

    $('.gm-style-iw > [style]').css('overflow: visible');
