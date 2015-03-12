tagService = ngInject ($resource) ->

  tags = $resource(
    '/art_piece_tags/:id'
    {}
    {
      get: { method: 'GET', cache: true }
    }
  )

  get:(id) ->
    tags.get({id: id})


angular.module('mau.services').factory('tagService', tagService)
