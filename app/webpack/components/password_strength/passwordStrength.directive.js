import angular from "angular";
import ngInject from "@js/ng-inject";
import zxcvbn from "zxcvbn";

(function () {
  var passwordStrength;

  passwordStrength = ngInject(function ($compile) {
    return {
      restrict: "A",
      link: function ($scope, $element, attrs) {
        var meter;
        meter =
          '<meter class="password-strength__meter" min="0" low="3" optimum="3" max="4" value="{{score}}"></meter>';
        $element.find("input").after($compile(meter)($scope));
        return $scope.$watch(attrs.passwordStrength, function (newVal) {
          if (newVal != null) {
            return ($scope.score = zxcvbn(newVal).score);
          }
        });
      },
      scope: true,
    };
  });

  angular
    .module("mau.directives")
    .directive("passwordStrength", passwordStrength);
}.call(this));
