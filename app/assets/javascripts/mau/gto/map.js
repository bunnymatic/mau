// Generated by CoffeeScript 1.12.7
(function() {
  $(function() {
    var $map, buildMap, handler, imagePath, map, pin, ref;
    if (typeof ClusterIcon !== "undefined" && ClusterIcon !== null) {
      ClusterIcon.prototype.getPosFromLatLng_ = function(latlng) {
        var pos;
        pos = this.getProjection().fromLatLngToDivPixel(latlng);
        pos.x -= parseInt(this.width_ / 2);
        pos.y -= parseInt(this.height_);
        return pos;
      };
    }
    $map = $("#map-canvas");
    if (($map != null ? $map[0] : void 0) && MAU.map_markers) {
      handler = null;
      imagePath = "/images/google_maps/js-marker-clusterer/";
      pin = {
        url: "/images/google_maps/google-map-pin.svg",
        size: new google.maps.Size(22, 40),
        origin: new google.maps.Point(0, 0),
        anchor: new google.maps.Point(11, 40)
      };
      buildMap = function() {
        var clusterStyles;
        if (handler) {
          return;
        }
        handler = Gmaps.build("Google");
        clusterStyles = _.map(
          ["1", "2", "3", "4", "5", "m1", "m2", "m3", "m4", "m5"],
          function(imgPrefix) {
            var fname;
            fname = imagePath + imgPrefix + ".png";
            return {
              url: fname,
              textColor: "white",
              textSize: 12,
              height: 70,
              lineHeight: 60,
              width: 33,
              backgroundPosition: "center bottom"
            };
          }
        );
        handler.setOptions({
          markers: {
            maxRandomDistance: 8,
            animation: google.maps.Animation.DROP,
            icon: pin,
            clusterer: {
              maxZoom: 17,
              gridSize: 20,
              imagePath: imagePath,
              styles: clusterStyles
            }
          }
        });
        handler.buildMap(
          {
            provider: {},
            internal: {
              id: "map-canvas"
            }
          },
          function() {
            var markers, polygons;
            markers = handler.addMarkers(_.compact(MAU.map_markers));
            handler.bounds.extendWith(markers);
            polygons = handler.addPolygons([MAU.map_bounds], {
              strokeColor: "#36828F3",
              strokeOpacity: 0.1,
              fillColor: "#c39f06",
              fillOpacity: 0.1
            });
            return handler.fitMapToBounds();
          }
        );
        $(".gm-style-iw > [style]").css("overflow: visible");
        return map;
      };
      if ((ref = $map.closest(".tab-content")) != null ? ref[0] : void 0) {
        return $("a[href=\\#map]").on("shown.bs.tab", function(ev) {
          var map;
          return (map = buildMap());
        });
      } else {
        return (map = buildMap());
      }
    }
  });
}.call(this));
