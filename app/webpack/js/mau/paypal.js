import jQuery from "jquery";

jQuery(function () {
  return jQuery("#donate_for_openstudios").on("click", function (ev) {
    ev.preventDefault();
    return jQuery("#paypal_donate_openstudios").submit();
  });
});
