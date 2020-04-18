import ngInject from "@angularjs/ng-inject";
import angular from "angular";

import template from "./index.html";

angular.module("mau.directives").directive(
  "linkIf",
  ngInject(function () {
    return {
      restrict: "E",
      scope: {
        href: "=",
        label: "=",
      },
      template: template,
    };
  })
);
