import angular from "angular";
import ngInject from "@angularjs/ng-inject";

const medium = ngInject(function (objectRoutingService) {
  return {
    restrict: "E",
    scope: {
      medium: "=",
    },
    template: '<a href="{{path}}" ng-bind-html="name"></a>',
    link: function ($scope, _el, _attrs) {
      const medium = $scope.medium;

      $scope.path = objectRoutingService.urlForModel("medium", medium);
      $scope.name = medium.name;
    },
  };
});
angular.module("mau.directives").directive("medium", medium);
