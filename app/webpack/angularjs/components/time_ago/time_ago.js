import ngInject from "@angularjs/ng-inject";
import angular from "angular";
import { DateTime } from "luxon";

const timeAgo = ngInject(function () {
  return {
    restrict: "E",
    scope: {
      time: "@",
    },
    template:
      "<span class='time-ago' title={{pacificTime}}>{{formattedTime}}</span>",
    link: function ($scope, _el, _attrs) {
      if ($scope.time) {
        $scope.pacificTime = DateTime.fromFormat(
          $scope.time,
          "yyyy-MM-dd HH:mm:ss z"
        );
        $scope.formattedTime = $scope.pacificTime.toRelative();
      }
    },
  };
});
angular.module("mau.directives").directive("timeAgo", timeAgo);
