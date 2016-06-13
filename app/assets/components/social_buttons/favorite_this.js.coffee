favoriteThis = ngInject (favoritesService) ->
  controller = ($scope) ->
    $scope.title ||= "Add to my favorites"

  controller.prototype.addFavorite = ( type, id ) ->
    r = favoritesService.add( type, id )

  link = (scope, elem, attrs, ctrl) ->
    $(elem).on 'click', ->
      ctrl.addFavorite(attrs.objectType, attrs.objectId).then(
        (data) ->
          message = data.message
          flash = new MAU.Flash()
          flash.clear()
          flash.show { notice: message }
        ,
        (err) ->
          message = err.message || "Something went wrong trying to add that favorite.  Please tell us what you were trying to do so we can fix it."
          flash = new MAU.Flash()
          flash.clear()
          flash.show { notice: message }
      )
  controller: controller
  restrict: 'E'
  templateUrl: 'social_buttons/favorite.html'
  scope: {}
  link: link
angular.module('mau.directives').directive('favoriteThis', favoriteThis)
