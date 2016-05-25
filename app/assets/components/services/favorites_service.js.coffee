favoritesService = ngInject ($resource, $q, currentUserService) ->

  favorites = $resource(
    '/users/:userId/favorites'
    { userId: "@userId" }
    {
      add:
        method: 'POST'
        params: {}
    }
  )
  add:( type, id) ->
    currentUserService.get().then (login) ->
      if login
        favorites.add( { userId: login }, { favorite: { type: type, id: id } })


angular.module('mau.services').factory('favoritesService', favoritesService)
