import jQuery from "jquery";
import { post } from "@js/mau_ajax";

const NUM_IMAGES = 12;

class Sampler {
  constructor(containerSelector) {
    this.$container = jQuery(containerSelector);

    const $win = jQuery(window);
    $win.scroll(() => {
      if ($win.scrollTop() === jQuery(document).height() - $win.height()) {
        return this.fetchArtists();
      }
    });
    this.fetchArtists();
  }

  async fetchArtists() {
    if (!this.$container.find("#js-scroll-load-more").length) {
      return;
    }
    const seed = this.$container.data("seed");
    const offset = this.$container.data("offset") || 0;
    const data = await post("/main/sampler", {
      seed: seed,
      offset: offset,
      number_of_images: NUM_IMAGES,
    });

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
