import jQuery from "jquery";

jQuery(function () {
  const $tabs = jQuery(".js-tabs");
  if (!($tabs.length === 0)) {
    return $tabs.tab();
  }
});
