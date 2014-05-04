angular.module('ArtPiecesApp.controllers', []).
  controller 'artPiecesController', ['$scope','$resource', ($scope, $resource) ->
    
    ArtPieces = $resource('/art_pieces/:artPieceId.json', {artPieceId:'@id'})
    Artists = $resource('/artists/:artistId.json', {artistId:'@id'})

    $scope.artist = null
    $scope.artPieces = []
    $scope.currentArtPiece = null
    $scope.current = null      

    $scope.$watch 'current', () ->
      ArtPieces.get {artPieceId: $scope.current}, (piece) ->
        $scope.currentArtPiece = piece.art_piece
      
    $scope.isCurrent = (apId) ->
      (''+$scope.current) == (''+apId)

    $scope.pathToMedium = () ->
      ("/media/" + currentArtPiece.medium.id) if currentArtPiece.medium

    $scope.hasTags = () ->
      $scope.currentArtPiece &&
        $scope.currentArtPiece.tags &&
          ($scope.currentArtPiece.tags.length > 0)
      
    $scope.init = (opts) ->
      artPieceId = opts.artPieceId
      artistId = opts.artistId
      ArtPieces.get {artPieceId: artPieceId}, (piece) ->
        $scope.currentArtPiece = piece
        $scope.current = artPieceId
      Artists.get {artistId: artistId}, (artist) ->
        $scope.artist = artist.artist
        $scope.artPieces = []
        artist.artpieces.map (item) ->
          ArtPieces.get {artPieceId: item.id}, (piece) ->
            $scope.artPieces.push(piece.art_piece)
  ]  
          
