import jQuery from "jquery";
import { get } from "@js/mau_ajax";

jQuery(function () {
  const fetchArtists = function (url) {
    var $content, nextPage, pagination;
    if (fetching) {
      return;
    }
    fetching = true;
    $content = jQuery(".js-artists-scroll-wrapper");
    pagination = jQuery(".js-pagination-state").last().data();
    if (pagination.hasMore) {
      nextPage = pagination.nextPage;
      get(url, {
        s: pagination.sortOrder,
        l: pagination.currentLetter,
        p: nextPage,
        os_only: pagination.osOnly,
      }).done(function (data) {
        jQuery("#js-scroll-load-more").remove();
        if (data) {
          $content = jQuery(".js-artists-scroll-wrapper");
          $content.append(data);
        }
        return (fetching = false);
      });
    }
  };

  let fetching;

  if (jQuery(".artists.show").length) {
    const $bio = jQuery(".artist__bio");
    if ($bio.length) {
      $bio.toggleClass("overflowing", $bio.isOverflowing());
    }
    $bio.next(".js-read-more").on("click", function (ev) {
      var t;
      ev.preventDefault();
      $bio.toggleClass("open");
      $bio.scrollTop(0);
      t = $bio.hasClass("open") ? "Read Less" : "Read More";
      return jQuery(this).find("span.text").html(t);
    });
    jQuery("#js-hide-artist-details").on("click", function (_ev) {
      let btnText;
      const $left = jQuery("#about");
      const $right = jQuery("#art");
      const $columns = $left.find(".artist-profile[class^=pure-u-]");
      $columns.first().toggleClass("pure-u-lg-1-2");
      $columns.last().toggleClass("collapsed pure-u-lg-1-2");
      $left.toggleClass(
        "pure-u-md-1-2 pure-u-md-1-3 pure-u-lg-1-5 pure-u-lg-2-5"
      );
      $right.toggleClass(
        "pure-u-md-1-2 pure-u-md-2-3 pure-u-lg-4-5 pure-u-lg-3-5"
      );
      btnText = jQuery(this).html();
      if (/hide/i.test(btnText)) {
        btnText = btnText.replace("Hide", "Show");
      } else {
        btnText = btnText.replace("Show", "Hide");
      }
      jQuery(this).html(btnText);
    });
  }

  if (jQuery(".artists.index, .open_studios.show").length) {
    fetching = false;

    const url =
      jQuery(".artists.index")[0] != null ? "/artists" : "/open_studios";

    const $win = jQuery(window);
    $win.scroll(function () {
      if ($win.scrollTop() === jQuery(document).height() - $win.height()) {
        return fetchArtists(url);
      }
    });
    const $more = jQuery("#js-scroll-load-more");
    if ($more.length && $more.position().top < $win.height()) {
      return fetchArtists(url);
    }
  }
});
