controller = ngInject ($scope, $attrs, artPiecesService, artistsService) ->

  initializeCurrent = ->
    if $scope.artPieces && $scope.initialArtPiece
      $scope.current = _.pluck($scope.artPieces, 'id').indexOf($scope.initialArtPiece.id)
      
  setCurrentArtPiece = () ->
    return unless $scope.artPieces
    console.log "Current ", $scope.current
    if !$scope.current || $scope.current < 0
      $scope.current = 0
    $scope.currentArtPiece = $scope.artPieces[$scope.current]

  limitPosition = (pos) ->
    nPieces = $scope.artPieces.length
    if (pos < 0)
      pos = nPieces + pos
    Math.min( Math.max(0, pos), nPieces ) % nPieces 

  $scope.prev = () ->
    $scope.current = limitPosition($scope.current - 1)

  $scope.next = () ->
    $scope.current = limitPosition($scope.current + 1)

  $scope.onKeyDown = (ev) ->
    if ev.which == 37
      $scope.prev()
    if ev.which == 39
      $scope.next()
    $scope.$apply()

  $scope.isCurrent = (artPieceId) ->
    $scope.currentArtPiece?.id == artPieceId
    
  $scope.setCurrent = ($event, $index) ->
    $event.preventDefault()
    $scope.current = $index

  $scope.hasYear = () ->
    !!$scope.currentArtPiece?.year
  $scope.hasDimensions = () ->
    !!$scope.currentArtPiece?.dimensions
  $scope.hasMedia = () ->
    !!$scope.currentArtPiece?.medium
  $scope.hasTags = () ->
    $scope.currentArtPiece?.tags &&
      ($scope.currentArtPiece.tags.length > 0)
    
    
  init = () ->
    artistId = $attrs.artistId
    artPieceId = $attrs.artPieceId
    
    artistsService.get(artistId).$promise.then (data) -> $scope.artist = data
    artPiecesService.list(artistId).$promise.then (data) -> $scope.artPieces = data
    artPiecesService.get(artPieceId).$promise.then (data) ->
      $scope.currentArtPiece = data
      $scope.initialArtPiece = data

    $scope.$watch( 'current', setCurrentArtPiece )
    $scope.$watch( 'artPieces', initializeCurrent )
    $scope.$watch( 'initialArtPiece', initializeCurrent )    


  init()
  
artPiecesBrowser = ($document) ->
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
