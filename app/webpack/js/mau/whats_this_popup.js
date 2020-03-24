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

jQuery(function () {
  jQuery(".js-help").each((_idx, el) => new WhatsThisPopup(el));
});

export { WhatsThisPopup };
