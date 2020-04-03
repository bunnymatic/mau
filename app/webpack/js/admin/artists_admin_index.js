import jQuery from "jquery";
import MauDatatables from "./mau_datatables.js";
import { ajaxSetup } from "@js/mau_ajax";

class ArtistsAdminIndex {
  constructor(tabPaneSelector, dataTablesSelector = ".js-data-tables") {
    ajaxSetup(jQuery);
    jQuery(tabPaneSelector).each(function (_idx, element) {
      const $pane = jQuery(element);
      const url = $pane.data("url");
      $pane.load(url, { method: "post" }, function () {
        new MauDatatables(jQuery).setupDataTables(
          $pane.find(dataTablesSelector)
        );
      });
    });
  }
}

export default ArtistsAdminIndex;
