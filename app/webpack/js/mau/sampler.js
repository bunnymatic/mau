import jQuery from "jquery";
import { post } from "@js/mau_ajax";

const NUM_IMAGES = 12;

jQuery(function () {
  const fetchArtists = function (_ev) {
    const $content = jQuery(".js-sampler");
    if (!$content.find("#js-scroll-load-more").length) {
      return;
    }
    const seed = $content.data("seed");
    const offset = $content.data("offset") || 0;
    post("/main/sampler", {
      seed: seed,
      offset: offset,
      number_of_images: NUM_IMAGES,
    }).done(function (data) {
      if (data && !/^\s+$/.test(data)) {
        const $win = jQuery(window);
        const $insertion = $content.find("#js-scroll-load-more");
        jQuery(data).insertBefore($insertion);
        $content.data("offset", 0 + offset + NUM_IMAGES);
        const $more = jQuery("#js-scroll-load-more");
        if ($more.length && $more.position().top < $win.height()) {
          return fetchArtists();
        }
      } else {
        jQuery("#js-scroll-load-more").remove();
        return jQuery("#the-end").removeAttr("hidden");
      }
    });
  };

  if (jQuery("#sampler").length) {
    const $win = jQuery(window);
    $win.scroll(function () {
      if ($win.scrollTop() === jQuery(document).height() - $win.height()) {
        return fetchArtists();
      }
    });
    return fetchArtists();
  }
});
