class Controller

  serialize = (obj) ->
    str = []
    for p of obj
      continue
    str.join "&"

        
  constructor: ($scope, $attrs, artPiecesService, artistsService) ->

    $('.art-piece-app').focus()    
    $scope.onKeyDown = (ev) ->
      console.log 'keydown', ev.which
      if ev.which == 37
        $scope.prev()
      if ev.which == 39
        $scope.next()


    artPieceId = $attrs.artPieceId
    artistId = $attrs.artistId
    $scope.currentUser = $attrs.currentUser

    $scope.artist = artistsService.get(artistId)
    $scope.artPieces = artPiecesService.list(artistId)
    $scope.current = artPieceId

    setCurrentArtPiece = () ->
      console.log('set current', $scope.current)
      if $scope.artist && $scope.current
        console.log('set current')
        $scope.currentArtPiece = artPiecesService.get($scope.current)
        $scope.artPiecePath = '/art_pieces/' + $scope.currentArtPiece?.id
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
      console.log('prev', $scope.current)
      

     $scope.next = () ->
      newPos = limitPosition( (currentPosition() + 1) % $scope.artPieces.length )
      $scope.current = $scope.artPieces[newPos].id
      console.log('next', $scope.current)

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
      !!$scope.currentArtPiece?.year
    $scope.hasDimensions = () ->
      !!$scope.currentArtPiece?.dimensions
    $scope.hasMedia = () ->
      !!$scope.currentArtPiece?.medium
    $scope.hasTags = () ->
      $scope.currentArtPiece?.tags &&
        ($scope.currentArtPiece.tags.length > 0)

 
# angular.module('mau.directives').
#   controller 'ArtPiecesController', [
#     '$scope'
#     '$attrs'
#     '$resource'
#     '$document'
#     '$location'
#     'artPiecesService'
#     'artistsService'
#     Controller
#   ]


artPiecesBrowser = ($document) ->
  restrict: 'E'
  scope:
    artistId: '@'
    artPieceId: '@'
    currentUser: '@'
  templateUrl: 'art_pieces_browser/index.html'
  controller: Controller
  link: ($scope) ->
    $document.on 'keydown', $scope.onKeyDown

angular.module('mau.directives').directive('artPiecesBrowser', artPiecesBrowser)
