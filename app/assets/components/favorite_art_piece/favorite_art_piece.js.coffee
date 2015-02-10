favoriteArtPiece = ->
  restrict: 'E'
  scope:
    currentArtPiece: "@"
  templateUrl: 'favorite_art_piece/index.html'
  link: ($scope, el, attrs) ->
    console.log('link favorite art piece', $scope.currentArtPiece)
    $(el).on 'click', (ev) ->
      debugger
      ev.preventDefault()
      console.log($scope.artPiece)
      console.log "favorite #{$scope.artPiece.id}"

angular.module('mau.directives').directive('favoriteArtPiece', favoriteArtPiece)
