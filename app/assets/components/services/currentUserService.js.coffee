currentUserService = ngInject ($q, $http) ->

  @currentUser = null
  get: () ->
    $http.get("/users/whoami").then (response) =>
      $q.when( response.data.current_user, null )

angular.module('mau.services').factory('currentUserService', currentUserService)
