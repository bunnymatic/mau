backgroundImg = ngInject () ->
  restrict: 'A'
  link: (scope, element, attrs) ->
    console.log(attrs)
    url = attrs.backgroundImg
    element.css(
      'background-image': 'url(' + url + ')'
      'background-size' : 'cover'
    )
angular.module('mau.directives').directive('backgroundImg', backgroundImg)
