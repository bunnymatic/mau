import jQuery from "jquery";

(function () {
  jQuery(function () {
    return jQuery(".js-os-combo-link").on("click", function (ev) {
      var $frm;
      ev.preventDefault();
      $frm = jQuery(".js-multi-form");
      $frm.slideToggle();
      return false;
    });
  });
}.call(this));
