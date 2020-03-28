import angular from "angular";
import ngInject from "@js/ng-inject";

const backgroundImg = ngInject(function () {
  return {
    restrict: "A",
    link: function (scope, element, attrs) {
      var url;
      url = attrs.backgroundImg;
      return element.css({
        "background-image": 'url("' + url + '")',
        "background-size": "cover",
        "background-position": "center center",
      });
    },
  };
});

angular.module("mau.directives").directive("backgroundImg", backgroundImg);
