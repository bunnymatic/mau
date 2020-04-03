import jQuery from "jquery";
import min from "lodash/min";
import max from "lodash/max";

jQuery(function () {
  const flashNotice = ".notice, .flash, .flash__notice, .flash__error";
  jQuery("body").on("click", flashNotice, function (_ev) {
    const _that = this;
    jQuery(_that).fadeOut({
      complete: function () {
        jQuery(_that).remove();
      },
    });
  });
  jQuery(flashNotice)
    .not(".flash__error")
    .each(function () {
      const _that = this;
      const timeout = min([20000, max([5000, 120 * this.innerText.length])]);

      setTimeout(function () {
        jQuery(_that).fadeOut();
      }, timeout);
    });
});
