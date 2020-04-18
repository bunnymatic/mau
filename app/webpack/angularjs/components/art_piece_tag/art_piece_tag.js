import ngInject from "@angularjs/ng-inject";
import angular from "angular";

const artPieceTag = ngInject(function (objectRoutingService) {
  return {
    restrict: "E",
    scope: {
      tag: "=",
    },
    template: '<a href="{{path}}" ng-bind-html="name"></a>',
    link: function ($scope, _el, _attrs) {
      const tag = $scope.tag;
      $scope.path = objectRoutingService.urlForModel("art_piece_tag", tag);
      $scope.name = tag.name;
    },
  };
});

angular.module("mau.directives").directive("artPieceTag", artPieceTag);
