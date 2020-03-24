import $ from "jquery";
import { post } from "@js/mau_ajax";

(function () {
  $(function () {
    var $win, NUM_IMAGES, fetchArtists;
    NUM_IMAGES = 12;
    fetchArtists = function (_ev) {
      var $content, offset, seed;
      $content = $(".js-sampler");
      if (!$content.find("#js-scroll-load-more").length) {
        return;
      }
      seed = $content.data("seed");
      offset = $content.data("offset") || 0;
      post("/main/sampler", {
        seed: seed,
        offset: offset,
        number_of_images: NUM_IMAGES,
      }).done(function (data) {
        var $insertion, $more;
        if (data && !/^\s+$/.test(data)) {
          $insertion = $content.find("#js-scroll-load-more");
          $(data).insertBefore($insertion);
          $content.data("offset", 0 + offset + NUM_IMAGES);
          $more = $("#js-scroll-load-more");
          if ($more.length && $more.position().top < $win.height()) {
            return fetchArtists();
          }
        } else {
          $("#js-scroll-load-more").remove();
          return $("#the-end").removeAttr("hidden");
        }
      });
    };
    if ($("#sampler").length) {
      $win = $(window);
      $win.scroll(function () {
        if ($win.scrollTop() === $(document).height() - $win.height()) {
          return fetchArtists();
        }
      });
      return fetchArtists();
    }
  });
}.call(this));
