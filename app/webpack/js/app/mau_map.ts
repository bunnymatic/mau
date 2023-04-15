import { post } from "@services/mau_ajax";
import MarkerClusterer from "@google/markerclustererplus";

const random = (min, max) => Math.random() * (max - min) + min;
const MAX_RANDOM_DISTANCE = 6;

type InputMarker = Record<string, any>;
type InputBound = Record<string, any>;
type LatLong = { lat: number, lng: number };
type MapInfoResponse = {
  map_markers: Array<InputMarker>,
  map_bounds: Array<InputBound>
};

class MauMap {
  map: google.maps.Map;
  currentOpenInfoWindow?: google.maps.InfoWindow | null;
  markers: Array<InputMarker>;
  bounds: Array<InputBound>;

  constructor(mapElementId: string, { markers, bounds }: { markers: Array<InputMarker>, bounds: Array<InputBound> }) {
    this.map = new google.maps.Map(document.getElementById(mapElementId), {});

    this.currentOpenInfoWindow = null;
    this.markers = markers;
    this.bounds = bounds;
  }

  randomizePosition(marker: InputMarker, maxRandomDistance: number | null = null): InputMarker | LatLong {
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
  }

  transformMarker(marker: InputMarker): InputMarker {
    const { lat, lng, artistName } = marker;
    return {
      ...marker,
      position: this.randomizePosition({ lat, lng }, MAX_RANDOM_DISTANCE),
      title: artistName,
    };
  }

  decorateMarker(marker: InputMarker): InputMarker {
    return { ...marker, animation: google.maps.Animation.DROP };
  }

  openInfoWindow(infoWindow: google.maps.InfoWindow, pin: google.maps.Marker): void {
    if (this.currentOpenInfoWindow) {
      this.currentOpenInfoWindow.close();
    }
    this.currentOpenInfoWindow = infoWindow;
    infoWindow.open(this.map, pin);
  }

  addMarkers() {
    return this.markers
      .filter((x) => !!x)
      .map((marker) => {
        const gmapMarker = this.decorateMarker(this.transformMarker(marker));
        const pin = new google.maps.Marker({ ...gmapMarker, map: this.map });
        const infoWindow = new google.maps.InfoWindow({
          content: marker.infowindow,
        });
        pin.addListener("click", () => this.openInfoWindow(infoWindow, pin));
        return pin;
      });
  }

  addBoundaryPolygon(): google.maps.Polygon {
    const poly = new google.maps.Polygon({
      paths: this.bounds,
      strokeColor: "#36828F3",
      strokeOpacity: 0.1,
      fillColor: "#c39f06",
      fillOpacity: 0.1,
    });
    poly.setMap(this.map);
    return poly;
  }

  getMarkerBounds(): google.maps.LatLngBounds {
    const bounds = new google.maps.LatLngBounds();
    this.bounds.forEach((bound) => bounds.extend(bound as google.maps.LatLngLiteral));
    this.markers.forEach((marker) => bounds.extend(marker as google.maps.LatLngLiteral));
    return bounds;
  }

  cluster(markers: Array<google.maps.Marker>) {
    const markerCluster = new MarkerClusterer(this.map, markers, {
      imagePath: "/images/google_maps/js-marker-clusterer/",
      zoomOnClick: true,
      maxZoom: 17,
      gridSize: 20,
    });
    return markerCluster;
  }

  render() {
    const markerBounds = this.getMarkerBounds();

    this.map.fitBounds(markerBounds);
    const pins = this.addMarkers();
    this.addBoundaryPolygon();
    this.cluster(pins);
  }

  static fetchAndRender(mapId: string) {
    post("/api/open_studios/map", {}).done((data: MapInfoResponse) => {
      new MauMap(mapId, {
        markers: data.map_markers,
        bounds: data.map_bounds,
      }).render();
    });
  };
}

export default MauMap;
