controller = ngInject ($scope, $attrs) ->
  c = this

  $scope.artPieceLink = () ->
    "http://missionartistsunited.org/art_pieces/#{$scope.artPiece.id}"

  $scope.description = () ->
    "Check out #{$scope.artPiece.title} by #{$scope.artPiece.artist_name} on Mission Artists United #{$scope.artPieceLink()} @sfmau"
    
  $scope.facebookLink = () ->
    safeStatus = encodeURIComponent($scope.artPieceLink())
    "https://www.facebook.com/sharer/sharer.php?u=#{safeStatus}"

  $scope.twitterLink = () ->
    safeStatus = encodeURIComponent($scope.description())
    "http://twitter.com?status=#{safeStatus}"

  $scope.pinterestLink = () ->
    artPiece = $scope.artPiece
    artPieceImage = encodeURIComponent("http://missionartistsuinted.org/#{artPiece.image_files.large}")
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
