import angular from "angular";
import ngInject from "@angularjs/ng-inject";

const mailer = ngInject(function ($window, mailerService) {
  return {
    restrict: "E",
    scope: {
      text: "@",
      name: "@",
      domain: "@",
      subject: "@",
    },
    template: "<a>{{text}}</a>",
    link: function ($scope, el, _attrs) {
      const $el = angular.element(el);

      $scope.openMailer = function (_ev) {
        $window.location = mailerService.mailToLink(
          $scope.subject,
          $scope.name,
          $scope.domain
        );
      };

      $el.bind("click", $scope.openMailer);
    },
  };
});
angular.module("mau.directives").directive("mailer", mailer);
