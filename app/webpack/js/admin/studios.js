import jQuery from "jquery";
import { post } from "@js/mau_ajax";
import Flash from "../mau/jquery/flash";
import map from "lodash/map";
import "jquery-ui";
import "jquery-ui/ui/widgets/sortable";
import "jquery-ui/ui/widgets/draggable";

jQuery(function () {
  if (jQuery(".admin.studios").length) {
    jQuery("#js-studio-arranger tbody").sortable({
      cursor: "move",
      start: function (_event, _ui) {},
      update: function (_event, ui) {
        const studioIds = map(
          jQuery(ui.item).closest("tbody").find("tr"),
          function (row) {
            return jQuery(row).data("studioId");
          }
        );
        post("/admin/studios/reorder", { studios: studioIds })
          .done(function (_data) {
            new Flash().show({
              notice: "Studio Order has been updated",
              timeout: 2000,
            });
          })
          .fail(function (_data) {
            new Flash().show({
              error: "There was trouble updating the studio order",
            });
            jQuery(ui.sender).sortable("cancel");
          });
      },
    });
  }
});
