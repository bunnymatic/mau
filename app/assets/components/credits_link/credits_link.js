/*global ngInject*/

(function() {
  var controller, Credits;

  controller = ngInject(function($scope, $attrs, $element, ngDialog) {
    $scope.launchModal = function($event) {
      $event.stopPropagation();
      $event.preventDefault();
      ngDialog.open({
        templateUrl: "credits_link/credits__modal.html",
        scope: $scope,
        className: "ngdialog-theme-default credits__modal",
        showClose: false
      });
    };
  });

  Credits = ngInject(function() {
    return {
      restrict: "E",
      scope: {
        versionString: "@"
      },
      templateUrl: "credits_link/index.html",
      controller: controller
    };
  });

  angular.module("mau.directives").directive("creditsLink", Credits);
}.call(this));
