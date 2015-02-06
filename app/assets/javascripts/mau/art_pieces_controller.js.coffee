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
    $scope.artist = Artists.get(artistId: artistId)
    $scope.artPieces = artPiecesService.list(artistId)
    $scope.current = artPieceId

    $scope.handleKeyDown = (ev) ->
      if ev.which == 37
        $scope.prev()
      if ev.which == 39
        $scope.next()

    setCurrentArtPiece = () ->
      if $scope.artist && $scope.current
        console.log('set current')
        $scope.currentArtPiece = artPiecesService.get($scope.current)
        $scope.artPiecePath = '/art_pieces/' + $scope.currentrtPiece?.id
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

    $scope.setArtPieceAsCurrent = ($event, id) ->
      $event.preventDefault()
      $scope.current = id

    $scope.hasYear = () ->
      !!$scope.currentArtPiece?.art_piece?.year
    $scope.hasDimensions = () ->
      !!$scope.currentArtPiece?.art_piece?.dimensions
    $scope.hasMedia = () ->
      !!$scope.currentArtPiece?.art_piece?.media
    $scope.hasTags = () ->
      $scope.currentArtPiece?.art_piece?.tags &&
        ($scope.currentArtPiece.art_piece.tags.length > 0)


  
angular.module('mau.controllers').
  controller 'ArtPiecesController', ['$scope','$attrs', '$resource','$document','artPiecesService', Controller]

