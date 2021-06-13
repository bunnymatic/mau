import { onEvent, onReady } from "@js/app/dom_helpers";
import jQuery from "jquery";

onReady(function () {
  const flashNotice = ".notice, .flash, .flash__notice, .flash__error";

  const onCallback = function (_ev) {
    const _that = this;
    jQuery(_that).fadeOut({
      complete: function () {
        jQuery(_that).remove();
      },
    });
  };

  onEvent("body", "click", flashNotice, onCallback);

  jQuery(flashNotice)
    .not(".flash__error")
    .each(function () {
      const _that = this;
      const timeout = Math.min(
        ...[20000, Math.max(...[5000, 120 * this.innerText.length])]
      );

      setTimeout(function () {
        jQuery(_that).fadeOut();
      }, timeout);
    });
});
