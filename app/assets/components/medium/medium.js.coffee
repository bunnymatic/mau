medium = ->
  restrict: 'E'
  scope:
    medium: "="
  templateUrl: 'medium/index.html'
  link: ($scope, el, attrs) ->
    medium = $scope.medium
    $scope.mediumPath = "/media/#{medium.id}"
    $scope.mediumName = medium.name

angular.module('mau.directives').directive('medium', medium)
