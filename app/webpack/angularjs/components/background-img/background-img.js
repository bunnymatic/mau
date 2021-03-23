import ngInject from "@angularjs/ng-inject";
import { backgroundImageStyle } from "@js/services/background_image.service";
import angular from "angular";

const backgroundImg = ngInject(function () {
  return {
    restrict: "A",
    link: function (_scope, element, attrs) {
      return element.css(backgroundImageStyle(attrs.backgroundImg));
    },
  };
});

angular.module("mau.directives").directive("backgroundImg", backgroundImg);
