angular.module('ArtPiecesApp.controllers', []).
  controller 'artPiecesController', ['$scope','$resource', ($scope, $resource) ->

    artPieceCache = {}
    
    serialize = (obj) ->
      str = []
      for p of obj
        continue
      str.join "&"
    
    ArtPieces = $resource('/art_pieces/:artPieceId.json', {artPieceId:'@id'}, {get: {method:'GET', cache:true}})
    Artists = $resource('/artists/:artistId.json', {artistId:'@id'}, {get: {method:'GET', cache:true}})

    $scope.artist = null
    $scope.artPieces = []
    $scope.currentArtPiece = null
    $scope.current = null      
  
    $scope.$watch 'current', () ->
      ArtPieces.get {artPieceId: $scope.current}, (piece) ->
        $scope.currentArtPiece = piece.art_piece
        $scope.artPiecePath = '/art_pieces/' + $scope.currentArtPiece.id
        $scope.editArtPiecePath = $scope.artPiecePath + "/edit"

    currentPosition = () ->
      $scope.artPieces.pluck('id').indexOf($scope.current)

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
      
    $scope.init = (opts) ->
      artPieceId = opts.artPieceId
      artistId = opts.artistId
      $scope.current = artPieceId
      Artists.get {artistId: artistId}, (artist) ->
        $scope.artist = artist.artist
        $scope.artPieces = []
        artist.artpieces.each (item) ->
          ArtPieces.get {artPieceId: item.id}, (piece) ->
            $scope.artPieces.push(piece.art_piece)
  ]  
          
