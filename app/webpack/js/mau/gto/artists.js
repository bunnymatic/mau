import $ from "jquery";
import { get } from "@js/mau_ajax";

(function () {
  $(function () {
    var $bio, $more, $win, fetchArtists, fetching, url;
    if ($(".artists.show").length) {
      $bio = $(".artist__bio");
      if ($bio.length) {
        $bio.toggleClass("overflowing", $bio.isOverflowing());
      }
      $bio.next(".js-read-more").on("click", function (ev) {
        var t;
        ev.preventDefault();
        $bio.toggleClass("open");
        $bio.scrollTop(0);
        t = $bio.hasClass("open") ? "Read Less" : "Read More";
        return $(this).find("span.text").html(t);
      });
      $("#js-hide-artist-details").on("click", function (_ev) {
        var $columns, $left, $right, btnText;
        $left = $("#about");
        $right = $("#art");
        $columns = $left.find(".artist-profile[class^=pure-u-]");
        $columns.first().toggleClass("pure-u-lg-1-2");
        $columns.last().toggleClass("collapsed pure-u-lg-1-2");
        $left.toggleClass(
          "pure-u-md-1-2 pure-u-md-1-3 pure-u-lg-1-5 pure-u-lg-2-5"
        );
        $right.toggleClass(
          "pure-u-md-1-2 pure-u-md-2-3 pure-u-lg-4-5 pure-u-lg-3-5"
        );
        btnText = $(this).html();
        if (/hide/i.test(btnText)) {
          btnText = btnText.replace("Hide", "Show");
        } else {
          btnText = btnText.replace("Show", "Hide");
        }
        return $(this).html(btnText);
      });
    }

    if ($(".artists.index, .open_studios.show").length) {
      fetching = false;

      fetchArtists = function (url) {
        var $content, nextPage, pagination;
        if (fetching) {
          return;
        }
        fetching = true;
        $content = $(".js-artists-scroll-wrapper");
        pagination = $(".js-pagination-state").last().data();
        if (pagination.hasMore) {
          nextPage = pagination.nextPage;
          get(url, {
            s: pagination.sortOrder,
            l: pagination.currentLetter,
            p: nextPage,
            os_only: pagination.osOnly,
          }).done(function (data) {
            $("#js-scroll-load-more").remove();
            if (data) {
              $content = $(".js-artists-scroll-wrapper");
              $content.append(data);
            }
            return (fetching = false);
          });
        }
      };
      url = $(".artists.index")[0] != null ? "/artists" : "/open_studios";
      $win = $(window);
      $win.scroll(function () {
        if ($win.scrollTop() === $(document).height() - $win.height()) {
          return fetchArtists(url);
        }
      });
      $more = $("#js-scroll-load-more");
      if ($more.length && $more.position().top < $win.height()) {
        return fetchArtists(url);
      }
    }
  });
}.call(this));
