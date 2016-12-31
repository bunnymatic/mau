passwordStrength = ngInject ($compile) ->
  restrict: 'A'
  link: ($scope, $element, attrs) ->

    meter = '<meter class="password-strength__meter" min="0" low="3" optimum="3" max="4" value="{{score}}"></meter>'
    $element.find('input').after($compile(meter)($scope))

    $scope.$watch attrs.passwordStrength, (newVal) ->
      if newVal?
        $scope.score = zxcvbn(newVal).score;
  scope: true

angular.module('mau.directives').directive 'passwordStrength', passwordStrength
