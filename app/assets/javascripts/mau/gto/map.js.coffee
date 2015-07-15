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
        handler.fitMapToBounds();
      )

      $('.gm-style-iw > [style]').css('overflow: visible');
   if ($map.closest('.tab-content')?[0])
     # on tab activate
     $('a[href=#map]').on 'shown.bs.tab', (ev) ->
       buildMap()

       
   else
     buildMap()
