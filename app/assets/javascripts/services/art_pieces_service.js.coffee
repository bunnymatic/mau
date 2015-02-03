class Service

  constructor: (@$http, @$q) ->
    @get_url = '/art_pieces/{{id}}.json'
    @index_url = '/artists/{{artistId}}/art_pieces.json'

  get:(id) ->
    url = @get_url.replace('{{id}}', id)
    @$http.get(url).then (result) -> result.data?.art_piece

  list:(artistId) ->
    url = @index_url.replace('{{artistId}}', artistId)
    @$http.get(url).then (result) ->
      console.log(result)
      _.map result.data, (item) -> item.art_piece
    
angular.module('ArtPiecesApp.services', []).service('ArtPiecesService', ['$http', '$q', Service])
