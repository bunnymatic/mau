import jQuery from "jquery";

jQuery(function () {
  jQuery(".js-os-combo-link").on("click", function (ev) {
    ev.preventDefault();
    const $frm = jQuery(".js-multi-form");
    $frm.slideToggle();
    return false;
  });
});
