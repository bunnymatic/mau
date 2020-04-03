import angular from "angular";
import ngInject from "@angularjs/ng-inject";

const timeAgo = ngInject(function (moment) {
  return {
    restrict: "E",
    scope: {
      time: "@",
    },
    template:
      "<span class='time-ago' title={{pacificTime}}>{{formattedTime}}</span>",
    link: function ($scope, _el, _attrs) {
      $scope.pacificTime = moment($scope.time).tz("America/Los_Angeles");
      $scope.formattedTime = moment($scope.time).fromNow();
    },
  };
});
angular.module("mau.directives").directive("timeAgo", timeAgo);
