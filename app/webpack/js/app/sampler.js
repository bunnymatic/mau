import { post } from "@services/mau_ajax";
import jQuery from "jquery";

const NUM_IMAGES = 12;

class RequestTracker {
  constructor() {
    this.requests = new Set();
  }

  static requestKey(seed, offset, count) {
    return [seed, offset, count].join("_");
  }

  isInFlight(seed, offset, count) {
    return this.requests.has(RequestTracker.requestKey(seed, offset, count));
  }

  start(seed, offset, count) {
    return this.requests.add(RequestTracker.requestKey(seed, offset, count));
  }

  stop(seed, offset, count) {
    return this.requests.delete(RequestTracker.requestKey(seed, offset, count));
  }
}

class Sampler {
  constructor(containerSelector) {
    this.$container = jQuery(containerSelector);
    this.requests = new RequestTracker();
    const $win = jQuery(window);
    $win.scroll(() => {
      if ($win.scrollTop() === jQuery(document).height() - $win.height()) {
        return this.fetchArtists();
      }
    });
    this.fetchArtists();
  }

  static requestKey(seed, offset, count) {
    return [seed, offset, count].join("_");
  }

  async fetchArtists() {
    if (!this.$container.find("#js-scroll-load-more").length) {
      return;
    }
    const seed = this.$container.data("seed");
    const offset = this.$container.data("offset") || 0;

    if (this.requests.isInFlight(seed, offset, NUM_IMAGES)) {
      return;
    }

    this.requests.start(seed, offset, NUM_IMAGES);
    const data = await post("/main/sampler", {
      seed: seed,
      offset: offset,
      number_of_images: NUM_IMAGES,
    });
    this.requests.stop(seed, offset, NUM_IMAGES);

    if (data && !/^\s+$/.test(data)) {
      const $win = jQuery(window);
      const $insertion = this.$container.find("#js-scroll-load-more");
      jQuery(data).insertBefore($insertion);
      this.$container.data("offset", 0 + offset + NUM_IMAGES);
      if ($insertion.length && $insertion.position().top < $win.height()) {
        return this.fetchArtists();
      }
    } else {
      const $insertion = this.$container.find("#js-scroll-load-more");
      $insertion.remove();
      return this.$container.find("#the-end").removeAttr("hidden");
    }
  }
}

export default Sampler;
