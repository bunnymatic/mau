$ ->
  $map = $('#map-canvas')
  if $map?[0] && MAU.map_markers
    handler = null

    buildMap = () ->
      return if handler
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
        polygons = handler.addPolygons([MAU.map_bounds], { strokeColor: "#36828F3", strokeOpacity: 0.1, fillColor: "#c39f06", fillOpacity: 0.1 });
        handler.bounds.extendWith(polygons);
        handler.fitMapToBounds();
      )

      $('.gm-style-iw > [style]').css('overflow: visible');
      map

    if ($map.closest('.tab-content')?[0])
      $('a[href=#map]').on 'shown.bs.tab', (ev) ->
         map = buildMap()
    else
      map = buildMap()
