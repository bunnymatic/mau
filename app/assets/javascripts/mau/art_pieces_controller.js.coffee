class Controller

  serialize = (obj) ->
    str = []
    for p of obj
      continue
    str.join "&"

        
  constructor: ($scope, $attrs, $resource, $document, artPiecesService) ->

    # ArtPieces = $resource('/artists/:artistId/art_pieces/:artPieceId.json',
    #   {artistId:'@artist.id', artPieceId:'@id'},
    #   {
    #     get: {method:'GET', cache:true},
    #     index: {method:'GET', cache:true, isArray: true}
    #   })
    Artists = $resource('/artists/:artistId.json', {artistId:'@id'}, {get: {method:'GET', cache:true}})
    
    artPieceId = $attrs.artPieceId
    artistId = $attrs.artistId

    $scope.artist = null
    $scope.currentArtPiece = null
    $scope.current = null
    $scope.artPieces = []

    console.log("init: artPieces", $scope.artPieces)      
    Artists.get {artistId: artistId}, (artist) ->
      $scope.artist = artist.artist
      numPieces = artist.artpieces.length
      setCurrentArtPiece()
      artPiecesService.list(artistId).then (data) ->
        $scope.artPieces = data
        console.log("fetched: artPieces", $scope.artPieces)      
        
        
    $scope.current = artPieceId

    $scope.handleKeyDown = (ev) ->
      if ev.which == 37
        $scope.prev()
      if ev.which == 39
        $scope.next()

    setCurrentArtPiece = () ->
      if $scope.artist && $scope.current
        artPiecesService.get $scope.current, (piece) ->
          $scope.currentArtPiece = piece.art_piece
          $scope.artPiecePath = '/art_pieces/' + $scope.currentArtPiece.id
          $scope.editArtPiecePath = $scope.artPiecePath + "/edit"

    $scope.$watch 'current', setCurrentArtPiece

    currentPosition = () ->
      _.pluck($scope.artPieces,'id').indexOf($scope.current)

    limitPosition = (pos) ->
      nPieces = $scope.artPieces.length
      if (pos < 0)
        pos = nPieces + pos
      Math.min( Math.max(0, pos), nPieces )

    $scope.prev = () ->
      newPos = limitPosition( (currentPosition() - 1) % $scope.artPieces.length )
      $scope.current = $scope.artPieces[newPos].id
    $scope.next = () ->
      newPos = limitPosition( (currentPosition() + 1) % $scope.artPieces.length )
      $scope.current = $scope.artPieces[newPos].id

    $scope.pinterestLikeLink = () ->
      ap = $scope.currentArtPiece
      return '' unless ap
      params =
        url: $scope.artPiecePath
        description: [ap.title, ap.artist_name].join(" by ")
        media: ap.image_files.large
      "http://pinterest.com/pin/create/button/?" + serialize(params)

    $scope.isCurrent = (apId) ->
      (''+$scope.current) == (''+apId)

    $scope.mediumPath = () ->
      ("/media/" + $scope.currentArtPiece.medium.id) if $scope.currentArtPiece && $scope.currentArtPiece.medium

    $scope.currentDisplayWidthStyle = () ->
      return {} unless $scope.currentArtPiece
      {width: $scope.currentArtPiece.image_dimensions.medium[0] + "px"}

    $scope.hasTags = () ->
      $scope.currentArtPiece &&
        $scope.currentArtPiece.tags &&
          ($scope.currentArtPiece.tags.length > 0)


  
angular.module('ArtPiecesApp.controllers', []).
  controller 'ArtPiecesController', ['$scope','$attrs', '$resource','$document','ArtPiecesService', Controller]

