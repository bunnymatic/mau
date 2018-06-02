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

  var M = MAU;

  // clear any errors and spinit
  M.waitcursor = function() {
    var errmsg = jQuery("#error_row");
    if (errmsg) {
      errmsg.html("");
    }
    var spinner = new MAU.Spinner();
    spinner.spin();
  };

  M.doSearch = function(_ev) {
    var q = jQuery("#search_box");
    var f = jQuery("#search_form");
    if (f.length && q.length && q.val()) {
      f.submit();
      return true;
    }
    return false;
  };

  M.mailer = function(name, domain, subject) {
    var lnk = "mailto:" + name + "@" + domain;
    if (subject && subject.length > -1) {
      lnk += "?subject=" + escape(subject);
    }
    window.location = lnk;
  };
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
