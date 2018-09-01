(function() {
  var mailerService;

  mailerService = ngInject(function() {
    return {
      mailToLink: function(subject, user, domain) {
        user = user || "www";
        domain = domain || "missionartistsunited.org";
        var lnk = "mailto:" + user + "@" + domain;
        if (subject && subject.length > -1) {
          lnk += "?subject=" + escape(subject);
        }
        return lnk;
      }
    };
  });

  angular.module("mau.services").factory("mailerService", mailerService);
}.call(this));
