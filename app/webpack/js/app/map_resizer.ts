import jQuery from "jquery";
import debounce from "lodash/debounce";
import { noop } from "@js/app/helpers";

class MapResizer {
  constructor(mapSelector: string, matchElementSelector: string) {
    const update = () => {
      const mapContainer = jQuery(mapSelector);
      const matchElement = jQuery(matchElementSelector);
      console.log({ w: matchElement.width() });
      mapContainer.width(matchElement.width());
    };

    const cb = () => window.requestAnimationFrame(update);
    const rIc = () => window.requestIdleCallback ? requestIdleCallback(cb, timeout) : noop;

    const timeout = { timeout: 2000 };
    const waitMs = 400;
    if (window.requestIdleCallback) {
      update();
    }
    jQuery(window).on("resize", debounce(rIc, waitMs));
  }
}

export default MapResizer;
