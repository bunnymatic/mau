import "jquery-ui";
import "jquery-ui/ui/widgets/sortable";

import Flash from "@js/app/jquery/flash";
import { postForm } from "@js/mau_ajax";
import jQuery from "jquery";

class ArrangeArtForm {
  constructor(formSelector) {
    this.formSelector = formSelector;

    var sortMe = jQuery(formSelector).find(".js-sortable");
    if (sortMe.sortable) {
      sortMe.sortable({
        update: function (_ev) {
          $(this).closest("form").submit();
        },
      });
    }

    jQuery(formSelector).on("submit", async function (ev) {
      ev.preventDefault();

      // construct new order
      const divs = jQuery(formSelector).find(".art-card[data-id]");
      const newOrderArray = divs
        .toArray()
        .map((el) => parseInt(jQuery(el).data("id"), 10));
      const newOrder = newOrderArray.join(",");

      jQuery(formSelector).append(
        jQuery("<input>", { type: "hidden", name: "neworder", value: newOrder })
      );

      const flash = new Flash();
      try {
        await postForm(formSelector);
        flash.show({ notice: "Nice!", timeout: 2000 });
      } catch (e) {
        flash.show({
          error:
            "Something went wrong.  We were unable to save the new order. Maybe try again later (and let us know there's a problem).",
        });
      }
    });
  }
}

export default ArrangeArtForm;
