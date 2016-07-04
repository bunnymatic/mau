studiosService = ngInject ($resource) ->

  studios = $resource(
    '/api/v2/studios/:id.json'
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
    if !id
      id = "independent-studios"
    studios.get({id: id})

angular.module('mau.services').factory('studiosService', studiosService)
