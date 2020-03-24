import angular from "angular";
import ngInject from "@js/ng-inject";

(function () {
  var medium;

  medium = ngInject(function () {
    return {
      restrict: "E",
      scope: {
        mediumId: "@",
        mediumSlug: "@",
        mediumName: "@",
      },
      templateUrl: "medium/index.html",
      link: function ($scope, _el, _attrs) {
        return ($scope.mediumPath =
          "/media/" + ($scope.mediumSlug || $scope.mediumId));
      },
    };
  });
  angular.module("mau.directives").directive("medium", medium);
}.call(this));
