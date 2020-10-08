import MarkerClusterer from "@google/markerclustererplus";
import jQuery from "jquery";

const random = (min, max) => Math.random() * (max - min) + min;
const MAX_RANDOM_DISTANCE = 6;
const randomizePosition = (marker, maxRandomDistance = null) => {
  if (!Number.isInteger(maxRandomDistance)) {
    return marker;
  }
  const MAGIC_DIVISOR = 6378137;
  const dx = maxRandomDistance * random(-1, 1);
  const dy = maxRandomDistance * random(-1, 1);
  const lat = marker.lat + (180.0 / Math.PI) * (dy / MAGIC_DIVISOR);
  const lng =
    marker.lng +
    ((90.0 / Math.PI) * (dx / MAGIC_DIVISOR)) / Math.cos(marker.lat);
  return { lat, lng };
};

const transformMarker = (marker) => {
  const { lat, lng, artistName } = marker;
  return {
    position: randomizePosition({ lat, lng }, MAX_RANDOM_DISTANCE),
    title: artistName,
  };
};

const decorateMarker = (marker) => {
  return { ...marker, animation: google.maps.Animation.DROP };
};

let currentOpenInfoWindow = null;
const openInfoWindow = (infoWindow, map, pin) => {
  if (currentOpenInfoWindow) {
    currentOpenInfoWindow.close();
  }
  currentOpenInfoWindow = infoWindow;
  return infoWindow.open(map, pin);
};
const addMarkers = (map, markers) => {
  return markers
    .filter((x) => !!x)
    .map((marker) => {
      const gmapMarker = decorateMarker(transformMarker(marker));
      const pin = new google.maps.Marker({ ...gmapMarker, map: map });
      const infoWindow = new google.maps.InfoWindow({
        content: marker.infowindow,
      });
      pin.addListener("click", () => openInfoWindow(infoWindow, map, pin));
      return pin;
    });
};

const addBoundaryPolygon = (map, bounds) => {
  const poly = new google.maps.Polygon({
    paths: bounds,
    strokeColor: "#36828F3",
    strokeOpacity: 0.1,
    fillColor: "#c39f06",
    fillOpacity: 0.1,
  });
  poly.setMap(map);
  return poly;
};

const getMarkerBounds = (markers, missionBounds) => {
  const bounds = new google.maps.LatLngBounds();
  missionBounds.forEach((bound) => bounds.extend(bound));
  markers.forEach((marker) => bounds.extend(marker));
  return bounds;
};

const cluster = (map, markers) => {
  const markerCluster = new MarkerClusterer(map, markers, {
    imagePath: "/images/google_maps/js-marker-clusterer/",
    zoomOnClick: true,
    maxZoom: 17,
    gridSize: 20,
  });
  return markerCluster;
};

const renderMap = (mapElementId) => {
  const missionBounds = MAU.map_bounds;
  const markers = MAU.map_markers;
  const markerBounds = getMarkerBounds(markers, missionBounds);

  const map = new google.maps.Map(document.getElementById(mapElementId), {});
  map.fitBounds(markerBounds);
  const pins = addMarkers(map, markers);
  addBoundaryPolygon(map, missionBounds);
  cluster(map, pins);
  return map;
};

jQuery(() => {
  let map;
  jQuery(document).on("show.bs.tab", (ev) => {
    if (ev.target.hash === "#map" && !map) {
      map = renderMap("map-canvas");
    }
  });
});
