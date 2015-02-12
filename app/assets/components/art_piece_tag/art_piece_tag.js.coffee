artPieceTag = ->
  restrict: 'E'
  scope:
    tag: "="
  templateUrl: 'art_piece_tag/index.html'
  link: ($scope, el, attrs) ->
    tag = $scope.tag
    $scope.tagPath = "/art_piece_tags/#{tag.id}"
    $scope.tagName = tag.name

angular.module('mau.directives').directive('artPieceTag', artPieceTag)
