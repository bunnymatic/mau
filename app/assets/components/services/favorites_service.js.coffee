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
    currentUserService.get().then( (login) ->
      if login
        favorites.add(
          { userId: login }, { favorite: { type: type, id: id } }
        ).$promise.then( (data) ->
          debugger
          { message: "Great choice for a favorite!  We added it to your collection." }
        ).catch( (err) ->
          {
            message: err.message || "That item doesn't seem to be available to favorite.  If you think it should be, please drop us a note and we'll look into it."
          }
        )
      else
        $q.when({ message: 'You need to login before you can favorite things' });
    ).catch( (err) ->
      $q.when(
        { message: 'You need to be logged in before you can favorite things' },
        { message: 'You need to be logged in before you can favorite things' }
      )
    )

angular.module('mau.services').factory('favoritesService', favoritesService)
