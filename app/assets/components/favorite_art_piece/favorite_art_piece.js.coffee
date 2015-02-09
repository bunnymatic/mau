favoriteArtPiece = ->
  restrict: 'E'
  scope:
    artPiece: "@currentArtPiece"
  templateUrl: 'favorite_art_piece/index.html'
  link: ($scope, el, attrs) ->
    console.log('link favorite art piece')
    $(el).on 'click', (ev) ->
      ev.preventDefault()
      console.log($scope.artPiece)
      console.log "favorite #{$scope.artPiece.id}"

angular.module('mau.directives').directive('favoriteArtPiece', favoriteArtPiece)
