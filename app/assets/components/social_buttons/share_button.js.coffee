controller = ngInject ($scope, $attrs, $location) ->
  c = this

  location_origin =  "#{$location.protocol()}://#{$location.host()}"
  if $location.port()? && $location.port() != 80
    location_origin += ":#{$location.port()}"

  $scope.domain = $attrs.domain || location_origin

  $scope.artPieceLink = () ->
    "#{@domain}/art_pieces/#{@artPiece.id}"

  $scope.description = () ->
    "Check out #{$scope.artPiece.title} by #{$scope.artPiece.artist_name} on Mission Artists"

  $scope.facebookLink = () ->
    safeUrl = encodeURIComponent($scope.artPieceLink())
    "https://www.facebook.com/sharer/sharer.php?u=#{safeUrl}"

  $scope.twitterLink = () ->
    safeStatus = encodeURIComponent($scope.description())
    artPieceUrl = encodeURIComponent($scope.artPieceLink())
    "http://twitter.com/intent/tweet?text=#{safeStatus}&via=sfmau&url=#{artPieceUrl}"

  $scope.pinterestLink = () ->
    artPiece = $scope.artPiece
    artPieceImage = encodeURIComponent("#{artPiece.image_urls.large}")
    title = encodeURIComponent(artPiece.title)
    desc = encodeURIComponent($scope.description())
    "https://pinterest.com/pin/create/button/?url=#{artPieceImage}&media=#{title}&description=#{desc}"

  $scope.link = () ->
    method = $attrs.type + 'Link'
    $scope[method]()

  $scope.target = () ->
    if ($attrs.type == 'favorite') then '_self' else '_blank'

  $scope.title = () ->
    switch $attrs.type
      when 'favorite' then 'Add this to your favorites'
      when 'twitter' then 'Tweet this'
      when 'facebook' then 'Share this on Facebook'
      when 'pinterest' then'Pin it'

  $scope.iconClass = () ->
    "ico-#{$attrs.type}"

shareButton = ->
  restrict: 'E'
  templateUrl: 'social_buttons/index.html'
  controller: controller
  controllerAs: "c"

angular.module('mau.directives').directive('shareButton', shareButton)
