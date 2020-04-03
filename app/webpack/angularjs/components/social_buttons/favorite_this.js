import angular from "angular";
import ngInject from "@angularjs/ng-inject";
import Flash from "@js/app/jquery/flash";
import template from "./favorite.html";

const controller = ngInject(function ($scope, favoritesService) {
  $scope.title = "Add to my favorites";
  $scope.addFavorite = function (type, id) {
    return favoritesService.add(type, id);
  };
});

const flashResponse = function (key, msg) {
  const flash = new Flash();
  return flash.show({
    [key]: msg,
    timeout: -1,
  });
};

const favoriteThis = ngInject(function () {
  const link = function (scope, elem, attrs) {
    const success = function (data) {
      return flashResponse("notice", data.message);
    };
    const error = function (err) {
      const message =
        err.message ||
        "Something went wrong trying to add that favorite.  Please tell us what you were trying to do so we can fix it.";
      flashResponse("error", message);
    };

    elem.bind("click", function () {
      scope.addFavorite(attrs.objectType, attrs.objectId).then(success, error);
    });
  };
  return {
    controller: controller,
    restrict: "E",
    template: template,
    scope: {},
    link: link,
  };
});

angular.module("mau.directives").directive("favoriteThis", favoriteThis);
