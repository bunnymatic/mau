import jQuery from "jquery";

class SlideToggler {
  constructor(trigger, thingToToggle) {
    jQuery(trigger).on("click", function (ev) {
      ev.preventDefault();
      const $thing = jQuery(thingToToggle);
      $thing.slideToggle();
      return false;
    });
  }
}

export default SlideToggler;
