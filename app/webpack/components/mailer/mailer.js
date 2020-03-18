import angular from "angular";
import ngInject from "@js/ng-inject";

(function() {
  var mailer;

  mailer = ngInject(function($window, mailerService) {
    return {
      restrict: "E",
      scope: {
        text: "@",
        name: "@",
        domain: "@",
        subject: "@"
      },
      templateUrl: "mailer/index.html",
      link: function($scope, el, _attrs) {
        var $el = angular.element(el);

        $scope.openMailer = function(_ev) {
          $window.location = mailerService.mailToLink(
            $scope.subject,
            $scope.name,
            $scope.domain
          );
        };

        $el.bind("click", $scope.openMailer);
      }
    };
  });
  angular.module("mau.directives").directive("mailer", mailer);
}.call(this));
