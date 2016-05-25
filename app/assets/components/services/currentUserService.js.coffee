currentUserService = ngInject ($q, $http) ->

  @currentUser = null
  get: () ->
    return $http.get("/users/whoami").then (response) =>
      defer = $q.defer()
      defer.resolve(response.data?.current_user)
      defer.reject(null)
      return defer.promise

angular.module('mau.services').factory('currentUserService', currentUserService)
