import jQuery from "jquery";

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
      const timeout = Math.min(
        ...[20000, Math.max(...[5000, 120 * this.innerText.length])]
      );

      setTimeout(function () {
        jQuery(_that).fadeOut();
      }, timeout);
    });
});
