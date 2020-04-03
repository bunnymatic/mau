import angular from "angular";
import ngInject from "@angularjs/ng-inject";
import zxcvbn from "zxcvbn";

const passwordStrength = ngInject(function ($compile) {
  return {
    restrict: "A",
    link: function ($scope, $element, attrs) {
      const meter =
        '<meter class="password-strength__meter" min="0" low="3" optimum="3" max="4" value="{{score}}"></meter>';
      $element.find("input").after($compile(meter)($scope));
      $scope.$watch(attrs.passwordStrength, function (newVal) {
        if (newVal != null) {
          $scope.score = zxcvbn(newVal).score;
        }
      });
    },
    scope: true,
  };
});

angular
  .module("mau.directives")
  .directive("passwordStrength", passwordStrength);
