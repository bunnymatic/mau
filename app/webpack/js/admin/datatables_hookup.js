import jQuery from "jquery";

import MauDatatables from "./mau_datatables";

jQuery(function () {
  new MauDatatables(jQuery).setupDataTables("body.admin .js-data-tables");
});
