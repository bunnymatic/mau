medium = ngInject () ->
  restrict: 'E'
  scope:
    mediumId: "@"
    mediumSlug: "@"
    mediumName: "@"
  templateUrl: 'medium/index.html'
  link: ($scope, el, attrs) ->
    $scope.mediumPath = "/media/#{$scope.mediumSlug || $scope.mediumId}"


angular.module('mau.directives').directive('medium', medium)
