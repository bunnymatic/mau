import jQuery from "jquery";
import debounce from 'lodash/debounce';

class MapResizer {
  constructor(mapSelector: string, matchElementSelector: string) {
    const update = () => {
      const mapContainer = jQuery(mapSelector);
      const matchElement = jQuery(matchElementSelector);
      console.log("update ", { w: mapContainer.width(), ww: matchElement.width() })
      mapContainer.width(matchElement.width())
    };

    const cb = () => window.requestAnimationFrame(update);
    const rIc = () => window.requestIdleCallback ? requestIdleCallback(cb, timeout) : cb;

    const timeout = { timeout: 2000 };
    const waitMs = 400;
    update()
    jQuery(window).on("resize", debounce(rIc, waitMs, { leading: true }));
  }
}

export default MapResizer;
