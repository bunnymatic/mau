//  Template includes both application.js and admin.js
//
//= require d3/dist/d3.min
//= require c3/c3.min
//= require_tree ./admin

(function() {
  angular
    .module("MauAdminApp", [
      "templates",
      "angularMoment",
      "ngSanitize",
      "ngDialog",
      "angularSlideables",
      "mau.models",
      "mau.services",
      "mau.directives"
    ])
    .config(
      ngInject(function($httpProvider) {
        var base, csrfToken;
        csrfToken = $("meta[name=csrf-token]").attr("content");
        $httpProvider.defaults.headers.post["X-CSRF-Token"] = csrfToken;
        $httpProvider.defaults.headers.post["Content-Type"] =
          "application/json";
        $httpProvider.defaults.headers.put["X-CSRF-Token"] = csrfToken;
        $httpProvider.defaults.headers.patch["X-CSRF-Token"] = csrfToken;
        (base = $httpProvider.defaults.headers)["delete"] ||
          (base["delete"] = {});
        $httpProvider.defaults.headers["delete"]["X-CSRF-Token"] = csrfToken;
        return null;
      })
    );
}.call(this));
