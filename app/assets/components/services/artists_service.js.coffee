artistsService = ngInject ($resource) ->

  artists = $resource(
    '/artists/:id.json'
    {}
    {
      get:
        method: 'GET'
        cache: true
        transformResponse: (data, header) ->
          angular.fromJson(data)?.artist
    }
  )
  get:(id) ->
    artists.get({id: id})

angular.module('mau.services').factory('artistsService', artistsService)
