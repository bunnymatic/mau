// Generated by CoffeeScript 1.12.7
(function() {
  var favoritesService;

  favoritesService = ngInject(function($resource, $q, currentUserService) {
    var favorites;
    favorites = $resource(
      "/users/:userId/favorites",
      {
        userId: "@userId"
      },
      {
        add: {
          method: "POST",
          params: {}
        }
      }
    );
    return {
      add: function(type, id) {
        return currentUserService
          .get()
          .then(function(login) {
            if (login) {
              return favorites
                .add(
                  {
                    userId: login
                  },
                  {
                    favorite: {
                      type: type,
                      id: id
                    }
                  }
                )
                .$promise.then(function(data) {
                  return {
                    message:
                      data.message ||
                      "Great choice for a favorite!  We added it to your collection."
                  };
                })
                ["catch"](function(err) {
                  return {
                    message:
                      err.message ||
                      "That item doesn't seem to be available to favorite.  If you think it should be, please drop us a note and we'll look into it."
                  };
                });
            } else {
              return $q.when({
                message: "You need to login before you can favorite things"
              });
            }
          })
          ["catch"](function(err) {
            return $q.when(
              {
                message:
                  "You need to be logged in before you can favorite things"
              },
              {
                message:
                  "You need to be logged in before you can favorite things"
              }
            );
          });
      }
    };
  });

  angular.module("mau.services").factory("favoritesService", favoritesService);
}.call(this));
