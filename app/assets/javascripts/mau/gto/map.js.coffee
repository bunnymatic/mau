$ ->
  if ClusterIcon?
    ClusterIcon.prototype.getPosFromLatLng_ = (latlng) ->
      pos = @getProjection().fromLatLngToDivPixel(latlng);
      pos.x -= parseInt(this.width_ / 2);
      pos.y -= parseInt(this.height_);
      pos

  $map = $('#map-canvas')
  if $map?[0] && MAU.map_markers
    handler = null
    imagePath = '/images/google_maps/js-marker-clusterer/'
    pin =
      url: '/images/google_maps/google-map-pin.svg'
      size: new google.maps.Size(22, 40)
      origin: new google.maps.Point(0, 0)
      anchor: new google.maps.Point(11, 40)

    buildMap = () ->
      return if handler
      handler = Gmaps.build('Google');

      clusterStyles = _.map ['1','2','3','4','5','m1','m2','m3','m4','m5'], (imgPrefix) ->
        fname = imagePath + imgPrefix + '.png';
        {
          url: fname
          textColor: 'white'
          textSize: 12
          height: 70
          lineHeight: 60
          width: 33
          backgroundPosition: 'center bottom'
        }
      handler.setOptions
        markers:
          maxRandomDistance: 8
          animation: google.maps.Animation.DROP,
          icon: pin,
          clusterer:
            maxZoom: 17
            gridSize: 20
            imagePath: imagePath
            styles: clusterStyles
      handler.buildMap({
        provider: {},
        internal:
          id: 'map-canvas'
      }, () ->
        markers = handler.addMarkers(_.compact(MAU.map_markers));
        handler.bounds.extendWith(markers);
        polygons = handler.addPolygons(
          [MAU.map_bounds],
          { strokeColor: "#36828F3", strokeOpacity: 0.1, fillColor: "#c39f06", fillOpacity: 0.1 }
        )
        handler.fitMapToBounds();
      )

      $('.gm-style-iw > [style]').css('overflow: visible');
      map

    if ($map.closest('.tab-content')?[0])
      $('a[href=#map]').on 'shown.bs.tab', (ev) ->
         map = buildMap()
    else
      map = buildMap()
