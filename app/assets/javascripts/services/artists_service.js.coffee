artistsService = ngInject ($resource) ->

  artists = $resource(
    '/artists/:id.json'
    {}
    {get: { method: 'GET', cache: true }}
  )
  get:(id) ->
    artists.get({id: id})

angular.module('mau.services').factory('artistsService', artistsService)
