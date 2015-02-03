class Service

  constructor: (@$http, @$q) ->
    @get_url = '/art_pieces/{{id}}.json'
    @index_url = '/artist/{{artistId}}/art_pieces.json'

  get:(id) ->
    url = @get_url.replace('{{id}}', id)
    @$http.get(url).then (result) -> result.data

  list:(artistId) ->
    url = @get_url.replace('{{artistId}}', artistId)
    @$http.get(url).then (result) -> result.data
    
angular.module('ArtPiecesApp.services', []).service('ArtPiecesService', ['$http', '$q', Service])
