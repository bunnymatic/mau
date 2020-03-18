import angular from "angular";
import ngInject from "@js/ng-inject";

(function() {
  var mailerService;

  mailerService = ngInject(function() {
    return {
      mailToLink: function(subject, user, domain) {
        if (!user || ["www", "info", "feedback", "mau"].indexOf(user) === -1) {
          user = "www";
        }
        domain = domain || "missionartists.org";
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
