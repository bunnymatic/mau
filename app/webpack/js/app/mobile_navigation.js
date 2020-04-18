import jQuery from "jquery";

class MobileNavigation {
  constructor(navWrapperSelector) {
    jQuery(navWrapperSelector).on(
      "click",
      ".js-nav-mobile, .js-close",
      function (ev) {
        ev.preventDefault();
        ev.stopPropagation();
        jQuery(this)
          .closest(navWrapperSelector)
          .find(".tab-content")
          .toggleClass("active");
      }
    );
  }
}

export default MobileNavigation;
