import angular from "angular";
import ngInject from "@js/ng-inject";

(function() {
  angular.module("mau.directives").directive(
    "linkIf",
    ngInject(function() {
      return {
        restrict: "E",
        scope: {
          href: "=",
          label: "="
        },
        templateUrl: "link_if/index.html"
      };
    })
  );
}.call(this));
