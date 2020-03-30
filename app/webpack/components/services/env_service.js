import angular from "angular";
import ngInject from "@js/ng-inject";

const envService = ngInject(function ($window) {
  return {
    isTest: () => $window.__env === "test",
    isDevelopment: () => $window.__env === "development",
    isProduction: function () {
      return !this.isTest() && !this.isDevelopment();
    },
  };
});

angular.module("mau.services").factory("envService", envService);
