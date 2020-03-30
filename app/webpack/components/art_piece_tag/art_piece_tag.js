import angular from "angular";
import ngInject from "@js/ng-inject";

const artPieceTag = ngInject(function (objectRoutingService) {
  return {
    restrict: "E",
    scope: {
      tag: "=",
    },
    template: '<a href="{{tagPath}}" ng-bind-html="tagName"></a>',
    link: function ($scope, _el, _attrs) {
      const tag = $scope.tag;
      $scope.tagPath = objectRoutingService.urlForModel("art_piece_tag", tag);
      $scope.tagName = tag.name;
    },
  };
});

angular.module("mau.directives").directive("artPieceTag", artPieceTag);
