favoriteThis = ngInject (favoritesService) ->
  controller = ($scope) ->
    $scope.title ||= "Add to my favorites"

  controller.prototype.addFavorite = ( type, id ) ->
    favoritesService.add( type, id )

  link = (scope, elem, attrs, ctrl) ->
    console.log(arguments)
    type = "Artist"
    id = "twenty"
    x = favoritesService.add(type, id)

    $(elem).find('a.favorite-this').on 'click', ->
      s = angular.element(@).parent().scope()
      type = id = null
      if (s.artPiece)
        type = 'ArtPiece'
        id = s.artPiece.id
      else
        type = 'Artist'
        id = s.artist.id
      r = ctrl.addFavorite(type, id)
      r.then(
        () ->
          flash = new MAU.Flash()
          flash.clear()
          flash.show { notice: "!!!" }
          console.log("success adding favorite")
        ,
        (err) ->
          flash = new MAU.Flash()
          flash.clear()
          flash.show { notice: err }
          console.log("failed to add favorite" )
      )
  controller: controller
  restrict: 'E'
  templateUrl: 'social_buttons/favorite.html'
  scope:
    favTitle: '='
  link: link
angular.module('mau.directives').directive('favoriteThis', favoriteThis)
