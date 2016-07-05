controller = ngInject ($scope, $attrs, $location) ->
  c = this

  util = MAU.QueryStringParserHelpers

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
    "https://www.facebook.com/sharer/sharer.php?" + util.hashToQueryString({ u: safeUrl })

  $scope.twitterLink = () ->
    safeDesc = encodeURIComponent($scope.description())
    artPieceUrl = encodeURIComponent($scope.artPieceLink())
    "http://twitter.com/intent/tweet?" + util.hashToQueryString({ text: safeDesc, via: 'sfmau', url: artPieceUrl })

  $scope.pinterestLink = () ->
    artPiece = $scope.artPiece
    artPieceImage = encodeURIComponent("#{artPiece.image_urls.large}")
    artPieceUrl = encodeURIComponent($scope.artPieceLink())
    title = encodeURIComponent(artPiece.title)
    desc = encodeURIComponent($scope.description())
    "https://pinterest.com/pin/create/button/?" + util.hashToQueryString( {
      url: artPieceUrl
      media: artPieceImage
      title: title,
      description: desc
    })

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
