import jQuery from "jquery";

class WhatsThisPopup {
  constructor(trigger) {
    const $trigger = jQuery(trigger);
    this.parentId = $trigger.data("parent");
    this.section = $trigger.data("section");
    this.helpTextDiv = `#${this.parentId}container`;
    $trigger.on("click", this.popup.bind(this));
    jQuery(this.helpTextDiv).on("click", this.popup.bind(this));
  }
  popup() {
    return jQuery(this.helpTextDiv).fadeToggle();
  }
}

export default WhatsThisPopup;
