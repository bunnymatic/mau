angular.module('ArtPiecesApp.controllers', []).
  controller 'artPiecesController', ['$scope','$resource','$document', ($scope, $resource, $document) ->

    artistId = undefined
    
    serialize = (obj) ->
      str = []
      for p of obj
        continue
      str.join "&"
    
    ArtPieces = $resource('/artists/:artistId/art_pieces/:artPieceId.json',
      {artistId:'@artist.id', artPieceId:'@id'},
      {
        get: {method:'GET', cache:true},
        index: {method:'GET', cache:true}
      })
    Artists = $resource('/artists/:artistId.json', {artistId:'@id'}, {get: {method:'GET', cache:true}})

    $scope.artist = null
    $scope.artPieces = []
    $scope.currentArtPiece = null
    $scope.current = null      

    $scope.handleKeyDown = (ev) ->
      if ev.which == 37
        $scope.prev()
      if ev.which == 39
        $scope.next()

    setCurrentArtPiece = () ->
      if $scope.artist && $scope.current
        ArtPieces.get {artistId: $scope.artist.id, artPieceId: $scope.current}, (piece) ->
          $scope.currentArtPiece = piece.art_piece
          $scope.artPiecePath = '/artists/' + artistId + '/art_pieces/' + $scope.currentArtPiece.id
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
      
    $scope.init = (opts) ->
      artPieceId = opts.artPieceId
      artistId = opts.artistId
      Artists.get {artistId: artistId}, (artist) ->
        $scope.artist = artist.artist
        $scope.artPieces = []
        numPieces = artist.artpieces.length
        setCurrentArtPiece()
        _.each artist.artpieces, (item,idx) ->
          ArtPieces.get {artistId: artistId, artPieceId: item.id}, (piece) ->
            $scope.artPieces[idx] = piece.art_piece
      $scope.current = artPieceId
            
  ]  
          
