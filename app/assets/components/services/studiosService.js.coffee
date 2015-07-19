studiosService = ngInject ($resource) ->

  studios = $resource(
    '/studios/:id.json'
    {}
    {
      get:
        method: 'GET'
        cache: true
        transformResponse: (data, header) ->
          angular.fromJson(data)?.studio
    }
  )
  get:(id) ->
    if (id == 0)
      id = "independent-studios"
    studios.get({id: id})

angular.module('mau.services').factory('studiosService', studiosService)
