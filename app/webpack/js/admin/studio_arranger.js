import Flash from "@js/app/flash";
import { map } from "@js/app/helpers";
import { post } from "@services/mau_ajax";
import jQuery from "jquery";
import Sortable from "sortablejs";

class StudioArranger {
  constructor(selector) {
    const el = jQuery(selector).find("tbody")[0];
    Sortable.create(el, {
      handle: ".fa.fa-bars",
      onStart: function (_event) {},
      onUpdate: function (event) {
        const studioIds = map(
          jQuery(event.item).closest("tbody").find("tr"),
          function (row) {
            return jQuery(row).data("studioId");
          }
        );
        return post("/admin/studios/reorder", { studios: studioIds })
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
          });
      },
    });
  }
}

export default StudioArranger;
