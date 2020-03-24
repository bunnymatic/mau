import jQuery from "jquery";
import "jquery-ui";
import "jquery-ui/ui/widgets/sortable";

jQuery(function () {
  /** arrange art */
  var sortMe = jQuery(
    "#arrange-art .js-sortable, .artists.arrange_art .js-sortable"
  );
  if (sortMe.sortable) {
    sortMe.sortable({
      update: function () {
        $(this).closest("form").submit();
      },
    });
  }

  jQuery("#arrange_art_form").bind("submit", function (_ev) {
    // construct new order
    var divs = jQuery(".art-card[data-id]");
    var newOrderArray = divs.toArray().map(function (el) {
      return parseInt(jQuery(el).data("id"), 10);
    });
    var newOrder = newOrderArray.join(",");
    jQuery(this).append(
      jQuery("<input>", { type: "hidden", name: "neworder", value: newOrder })
    );
  });
});
