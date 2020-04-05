import angular from "angular";
import ngInject from "@js/ng-inject";
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