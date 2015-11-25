artPiecesService = ngInject ($resource) ->

  artPieces = $resource(
    '/api/v2/artists/:id/art_pieces.json'
    {}
    {
      index:
        method: 'GET'
        cache: true
        isArray: true
    }
  )
  artPiece = $resource(
    '/api/v2/art_pieces/:id.json'
    {}
    {
      get:
        method: 'GET'
        cache: true
        transformResponse: (data, header) ->
          angular.fromJson(data)?.art_piece
    }
  )
  get:(id) ->
    artPiece.get({id: id})

  list:(artistId) ->
    artPieces.index({id: artistId})

angular.module('mau.services').factory('artPiecesService', artPiecesService)
