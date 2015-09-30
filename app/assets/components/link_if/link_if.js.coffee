angular.module('mau.directives').directive 'linkIf', ngInject () ->
  restrict: 'E',
  scope:
    href: '='
    label: '='
  templateUrl: 'link_if/index.html'



