medium = ngInject () ->
  restrict: 'E'
  scope:
    mediumId: "@"
    mediumName: "@"
  templateUrl: 'medium/index.html'
  link: ($scope, el, attrs) ->
    $scope.mediumPath = "/media/#{$scope.mediumId}"
    

angular.module('mau.directives').directive('medium', medium)
