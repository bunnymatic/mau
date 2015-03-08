controller = ngInject ($scope, $attrs, artPiecesService, artistsService) ->

  initializeCurrent = ->
    if $scope.artPieces && $scope.initialArtPiece
      $scope.current = _.pluck($scope.artPieces, 'id').indexOf($scope.initialArtPiece.id)

  setCurrentArtPiece = () ->
    return unless $scope.artPieces
    if !$scope.current || $scope.current < 0
      $scope.current = 0
    $scope.artPiece = $scope.artPieces[$scope.current]

  limitPosition = (pos) ->
    nPieces = $scope.artPieces.length
    if (pos < 0)
      pos = nPieces + pos
    Math.min( Math.max(0, pos), nPieces ) % nPieces

  $scope.prev = () ->
    $scope.current = limitPosition($scope.current - 1)

  $scope.next = () ->
    $scope.current = limitPosition($scope.current + 1)

  $scope.currentArtPath = () ->
    "/art_pieces/" + $scope.artPiece?.id
  $scope.currentArtistPath = () ->
    "/artists/" + $scope.artist?.id

  $scope.onKeyDown = (ev) ->
    if ev.which == 37
      $scope.prev()
    if ev.which == 39
      $scope.next()
    $scope.$apply()

  $scope.isCurrent = (artPieceId) ->
    $scope.artPiece?.id == artPieceId

  $scope.setCurrent = ($event, $index) ->
    $event.preventDefault()
    $scope.current = $index

  $scope.hasYear = () ->
    !!$scope.artPiece?.year
  $scope.hasDimensions = () ->
    !!$scope.artPiece?.dimensions
  $scope.hasMedia = () ->
    !!$scope.artPiece?.medium
  $scope.hasTags = () ->
    $scope.artPiece?.tags &&
      ($scope.artPiece.tags.length > 0)


  init = () ->
    artistId = $attrs.artistId
    artPieceId = $attrs.artPieceId

    artistsService.get(artistId).$promise.then (data) -> $scope.artist = data
    artPiecesService.list(artistId).$promise.then (data) -> $scope.artPieces = data
    artPiecesService.get(artPieceId).$promise.then (data) ->
      $scope.artPiece = data
      $scope.initialArtPiece = data


    $scope.$watch( 'current', setCurrentArtPiece )
    $scope.$watch( 'artPieces', initializeCurrent )
    $scope.$watch( 'initialArtPiece', initializeCurrent )


  init()

artPiecesBrowser = ngInject ($document) ->
  restrict: 'E'
  scope:
    artistId: '@'
    artPieceId: '@'
    currentUser: '@'
  templateUrl: 'art_pieces_browser/index.html'
  controller: controller
  controllerAs: 'c'
  link: ($scope, $el, $attr, $ctrl) ->
    $document.on 'keydown', $scope.onKeyDown

angular.module('mau.directives').directive('artPiecesBrowser', artPiecesBrowser)
