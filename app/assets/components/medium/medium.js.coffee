medium = ngInject () ->
  restrict: 'E'
  scope:
    mediumId: "@"
    mediumName: "@"
  templateUrl: 'medium/index.html'
  link: ($scope, el, attrs) ->
    

angular.module('mau.directives').directive('medium', medium)
