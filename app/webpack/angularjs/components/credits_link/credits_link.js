import ngInject from "@angularjs/ng-inject";
import angular from "angular";

import modalTemplate from "./credits__modal.html";
import template from "./index.html";

const controller = ngInject(function ($scope, $attrs, $element, ngDialog) {
  $scope.launchModal = function ($event) {
    $event.stopPropagation();
    $event.preventDefault();
    ngDialog.open({
      className: "ngdialog-theme-default credits__modal",
      plain: true,
      scope: $scope,
      showClose: false,
      template: modalTemplate,
    });
  };
});

const credits = ngInject(function () {
  return {
    restrict: "E",
    scope: {
      versionString: "@",
    },
    template: template,
    controller: controller,
  };
});

angular.module("mau.directives").directive("creditsLink", credits);
