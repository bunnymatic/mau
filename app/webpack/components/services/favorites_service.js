import angular from "angular";
import ngInject from "@js/ng-inject";

(function () {
  var favoritesService;

  var MUST_LOGIN_MESSAGE = "You need to login before you can favorite things";

  favoritesService = ngInject(function ($resource, $q, currentUserService) {
    var favorites;
    favorites = $resource(
      "/users/:userId/favorites",
      {
        userId: "@userId",
      },
      {
        add: {
          method: "POST",
          params: {},
        },
      }
    );
    return {
      add: function (type, id) {
        return currentUserService
          .get()
          .then(function (data) {
            var userInfo = data.current_user;
            if (userInfo.slug) {
              return favorites
                .add(
                  {
                    userId: userInfo.slug,
                  },
                  {
                    favorite: {
                      type: type,
                      id: id,
                    },
                  }
                )
                .$promise.then(function (data) {
                  return {
                    message:
                      data.message ||
                      "Great choice for a favorite!  We added it to your collection.",
                  };
                })
                ["catch"](function (err) {
                  return {
                    message:
                      err.message ||
                      "That item doesn't seem to be available to favorite.  If you think it should be, please drop us a note and we'll look into it.",
                  };
                });
            } else {
              return $q.when({
                message: MUST_LOGIN_MESSAGE,
              });
            }
          })
          ["catch"](function (_err) {
            return $q.when(
              {
                message: MUST_LOGIN_MESSAGE,
              },
              {
                message: MUST_LOGIN_MESSAGE,
              }
            );
          });
      },
    };
  });

  angular.module("mau.services").factory("favoritesService", favoritesService);
}.call(this));
