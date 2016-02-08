artPieceTag = ngInject (objectRoutingService) ->
  restrict: 'E'
  scope:
    tag: "="
  templateUrl: 'art_piece_tag/index.html'
  link: ($scope, el, attrs) ->
    tag = $scope.tag
    $scope.tagPath = objectRoutingService.urlForModel( "art_piece_tag", tag)
    $scope.tagName = tag.name

angular.module('mau.directives').directive('artPieceTag', artPieceTag)
