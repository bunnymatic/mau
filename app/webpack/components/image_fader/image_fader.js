import angular from "angular";
import ngInject from "@js/ng-inject";

(function() {
  angular.module("mau.directives").directive(
    "imageFader",
    ngInject(function(_$timeout) {
      return {
        restrict: "A",
        link: function($scope, $element, _attrs) {
          $element.addClass("ng-hide-remove");
          return $element.on("load", function() {
            return $element.addClass("ng-hide-add");
          });
        }
      };
    })
  );
}.call(this));
