import angular from "angular";
import ngInject from "@js/ng-inject";

(function () {
  var envService;

  envService = ngInject(function ($window) {
    return {
      isTest: function () {
        return $window.__env === "test";
      },
      isDevelopment: function () {
        return $window.__env === "development";
      },
      isProduction: function () {
        return !this.isTest() && !this.isDevelopment();
      },
    };
  });

  angular.module("mau.services").factory("envService", envService);
}.call(this));
