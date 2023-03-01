import Flash from "@js/app/flash";
import Spinner from "@js/app/spinner";
import { postForm } from "@services/mau_ajax";
import jQuery from "jquery";
import Sortable from "sortablejs";

class ArrangeArtForm {
  constructor(formSelector) {
    this.formSelector = formSelector;

    const spinnerId = "arrange-art-form-spinner";
    const spinnerEl = document.createElement("div");
    spinnerEl.id = spinnerId;
    $(this.formSelector).append(spinnerEl);

    const el = jQuery(formSelector).find(".js-sortable")[0];

    if (el) {
      Sortable.create(el, {
        onUpdate: function (_ev) {
          const $form = $(el).closest("form");
          $form.submit();
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
      const spinner = new Spinner({ element: `#${spinnerId}` });

      try {
        spinner.spin();
        await postForm(formSelector);
        flash.show({ notice: "Got it. Great arrangement!", timeout: 2000 });
      } catch (e) {
        console.warn(e);
        flash.show({
          error:
            "Something went wrong.  We were unable to save the new order. Maybe try again later (and let us know there's a problem).",
        });
      } finally {
        spinner.stop();
      }
    });
  }
}

export default ArrangeArtForm;
