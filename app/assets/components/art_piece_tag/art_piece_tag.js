// Generated by CoffeeScript 1.12.7
(function() {
  var artPieceTag;

  artPieceTag = ngInject(function(objectRoutingService) {
    return {
      restrict: "E",
      scope: {
        tag: "="
      },
      templateUrl: "art_piece_tag/index.html",
      link: function($scope, _el, _attrs) {
        var tag;
        tag = $scope.tag;
        $scope.tagPath = objectRoutingService.urlForModel("art_piece_tag", tag);
        return ($scope.tagName = tag.name);
      }
    };
  });

  angular.module("mau.directives").directive("artPieceTag", artPieceTag);
}.call(this));
