import ngInject from "@angularjs/ng-inject";
import angular from "angular";

const MUST_LOGIN_MESSAGE = "You need to login before you can favorite things";

const favoritesService = ngInject(function ($resource, $q, currentUserService) {
  const favorites = $resource(
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
          const { slug } = data.current_user;
          if (slug) {
            return favorites
              .add(
                {
                  userId: slug,
                },
                {
                  favorite: {
                    type: type,
                    id: id,
                  },
                }
              )
              .$promise.then(function ({ message }) {
                return {
                  message:
                    message ||
                    "Great choice for a favorite!  We added it to your collection.",
                };
              })
              ["catch"](function ({ message }) {
                return {
                  message:
                    message ||
                    "That item doesn't seem to be available to favorite.  If you think it should be, please drop us a note and we'll look into it.",
                };
              });
          }
          return $q.when({
            message: MUST_LOGIN_MESSAGE,
          });
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
