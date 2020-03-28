import angular from "angular";
import ngInject from "@js/ng-inject";
import template from "./index.html";

const medium = ngInject(function () {
  return {
    restrict: "E",
    scope: {
      mediumId: "@",
      mediumSlug: "@",
      mediumName: "@",
    },
    template: template,
    link: function ($scope, _el, _attrs) {
      return ($scope.mediumPath =
        "/media/" + ($scope.mediumSlug || $scope.mediumId));
    },
  };
});
angular.module("mau.directives").directive("medium", medium);
