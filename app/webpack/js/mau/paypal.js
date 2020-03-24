import $ from "jquery";

(function () {
  $(function () {
    return $("#donate_for_openstudios").on("click", function (ev) {
      ev.preventDefault();
      return $("#paypal_donate_openstudios").submit();
    });
  });
}.call(this));
