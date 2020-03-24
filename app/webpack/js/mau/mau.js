/*eslint no-unused-vars: 0*/
import jQuery from "jquery";
import min from "lodash/min";
import max from "lodash/max";

/** setup hash change observer */
(function () {
  let curHash = window.location.hash;
  function doHashChange() {
    if (window.location.hash != curHash) {
      curHash = window.location.hash;
      jQuery(document).trigger("mau:hashchange");
    }
  }
  if ("onhashchange" in window) {
    window.onhashchange = doHashChange;
  } else {
    window.setInterval(doHashChange, 20);
  }
})();

/*** jquery on load */
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
