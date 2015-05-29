angular.module('mau.directives').directive 'imageFader', ngInject ($timeout) ->
  restrict: 'A',
  link: ($scope, $element, attrs) ->
    $element.addClass("ng-hide-remove")
    $element.on 'load', () ->
      $element.addClass("ng-hide-add")
