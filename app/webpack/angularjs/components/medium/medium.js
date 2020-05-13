import ngInject from "@angularjs/ng-inject";
import angular from "angular";

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

      $scope.$watch(
        "medium",
        function (newMedium, oldMedium) {
          if (newMedium.id !== oldMedium.id) {
            $scope.name = newMedium.name;
            $scope.path = objectRoutingService.urlForModel("medium", newMedium);
          }
        },
        true
      );
    },
  };
});
angular.module("mau.directives").directive("medium", medium);
