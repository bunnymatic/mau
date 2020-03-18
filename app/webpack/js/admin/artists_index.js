import jQuery from "jquery";
import MauDatatables from "./mau_datatables.js";
import { ajaxSetup } from "@js/mau_ajax";

jQuery(function() {
  ajaxSetup(jQuery);

  jQuery(".tab-content .tab-pane[data-url]").each(function() {
    var $pane = jQuery(this);
    var url = $pane.data("url");
    $pane.load(url, { method: "post" }, function() {
      new MauDatatables(jQuery).setupDataTables($pane.find(".js-data-tables"));
    });
  });
});
