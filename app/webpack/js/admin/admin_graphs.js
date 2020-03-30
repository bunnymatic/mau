import jQuery from "jquery";
import { GraphPerDay, PlainGraph } from "./graph_helpers";

jQuery(function () {
  if (jQuery("body.admin .graph").length) {
    GraphPerDay.load(
      "#artists_per_day",
      "/admin/stats/artists_per_day",
      "artists"
    );
    GraphPerDay.load(
      "#user_visits_per_day",
      "/admin/stats/user_visits_per_day",
      "visits"
    );
    GraphPerDay.load(
      "#favorites_per_day",
      "/admin/stats/favorites_per_day",
      "favorites"
    );
    GraphPerDay.load(
      "#art_pieces_per_day",
      "/admin/stats/art_pieces_per_day",
      "pieces"
    );
    GraphPerDay.load("#os_signups", "/admin/stats/os_signups", "sign ups");

    PlainGraph.load(
      "#art_pieces_histogram",
      "/admin/stats/art_pieces_count_histogram",
      "# pieces",
      "# artists"
    );
  }
});
