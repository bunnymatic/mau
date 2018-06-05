/*eslint no-unused-vars: 0*/
var MAU = (window.MAU = window.MAU || {});

/** setup hash change observer */
(function() {
  var curHash = window.location.hash;
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
jQuery(function() {
  var flashNotice = ".notice, .flash, .flash__notice, .flash__error";
  $("body").on("click", flashNotice, function(_ev) {
    var $_that = $(this);
    $_that.fadeOut({
      complete: function() {
        $_that.remove();
      }
    });
  });
  jQuery(flashNotice)
    .not(".flash__error")
    .each(function() {
      var _that = this;
      var timeout = _.min([20000, _.max([5000, 120 * this.innerText.length])]);

      setTimeout(function() {
        $(_that).fadeOut();
      }, timeout);
    });
});
