(function() {
  var timeAgo;

  timeAgo = ngInject(function(moment, $timeout) {
    return {
      restrict: "E",
      scope: {
        time: "@"
      },
      template:
        "<span class='time-ago' title={{pacificTime}}>{{formattedTime}}</span>",
      link: function($scope, _el, _attrs) {
        var setTime = function() {
          $scope.pacificTime = moment($scope.time).tz("America/Los_Angeles");
          if ($scope.time) {
            $scope.formattedTime = moment($scope.time).fromNow();
          } else {
            $scope.formattedTime = "never";
          }
        };
        $timeout(setTime, 0);
      }
    };
  });
  angular.module("mau.directives").directive("timeAgo", timeAgo);
}.call(this));
