backgroundImg = ngInject () ->
  restrict: 'A'
  link: (scope, element, attrs) ->
    url = attrs.backgroundImg
    element.css(
      'background-image': 'url(' + url + ')'
      'background-size' : 'cover'
      'background-position': 'center center'
    )
angular.module('mau.directives').directive('backgroundImg', backgroundImg)
