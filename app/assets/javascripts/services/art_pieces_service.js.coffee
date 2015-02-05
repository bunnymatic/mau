class Service

  cache = {}

  constructor: (@$http, @$q) ->
    @get_url = '/art_pieces/{{id}}.json'
    @index_url = '/artists/{{artistId}}/art_pieces.json'

  get:(id) ->
    return cache[id] if cache[id]
    url = @get_url.replace('{{id}}', id)
    @$http.get(url).then (result) ->
      ap = result.data?.art_piece
      if ap?
        cache[id] = ap
      ap

  list:(artistId) ->
    url = @index_url.replace('{{artistId}}', artistId)
    console.log(url)
    @$http.get(url).then (result) ->
      console.log("service fetched: artPieces", result)
      _.map result.data, (item) -> item.art_piece
    
angular.module('ArtPiecesApp.services', []).service('ArtPiecesService', ['$http', '$q', Service])
