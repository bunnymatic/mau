import ngInject from "@angularjs/ng-inject";
import angular from "angular";

angular
  .module("MauApp", [
    "ngSanitize",
    "ngDialog",
    "mailchimp",
    "angularSlideables",
    "ui.keypress",
    "mau.models",
    "mau.services",
    "mau.directives",
  ])
  .config(
    ngInject(function ($locationProvider, $httpProvider) {
      var base, csrfToken;
      $locationProvider.html5Mode(false);
      $locationProvider.hashPrefix("!");
      csrfToken = $("meta[name=csrf-token]").attr("content");
      $httpProvider.defaults.headers.post["X-CSRF-Token"] = csrfToken;
      $httpProvider.defaults.headers.post["Content-Type"] = "application/json";
      $httpProvider.defaults.headers.put["X-CSRF-Token"] = csrfToken;
      $httpProvider.defaults.headers.patch["X-CSRF-Token"] = csrfToken;
      (base = $httpProvider.defaults.headers)["delete"] ||
        (base["delete"] = {});
      $httpProvider.defaults.headers["delete"]["X-CSRF-Token"] = csrfToken;
      return null;
    })
  );
