import angular from "angular";
import ngInject from "@angularjs/ng-inject";

const imageFader = ngInject(function (_$timeout) {
  return {
    restrict: "A",
    link: function ($scope, $element, _attrs) {
      $element.addClass("ng-hide-remove");
      $element.on("load", () => $element.addClass("ng-hide-add"));
    },
  };
});

angular.module("mau.directives").directive("imageFader", imageFader);
