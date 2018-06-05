(function() {
  var MAU = (window.MAU = window.MAU || {});

  MAU.mailer = function(name, domain, subject) {
    var lnk = "mailto:" + name + "@" + domain;
    if (subject && subject.length > -1) {
      lnk += "?subject=" + escape(subject);
    }
    window.open(lnk, "_blank");
  };
}.call(this));
