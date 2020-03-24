import angular from "angular";
import ngInject from "@js/ng-inject";

(function () {
  var emailListsService;

  emailListsService = ngInject(function ($resource) {
    var email_lists;
    email_lists = $resource(
      "/admin/email_lists/:email_list_id/emails/:id.json",
      {},
      {
        get: {
          method: "GET",
          cache: true,
          transformResponse: function (data, _header) {
            var ref;
            return (ref = angular.fromJson(data)) != null
              ? ref.email_lists
              : void 0;
          },
        },
      }
    );
    return {
      get: function (id) {
        return email_lists.get({
          id: id,
        });
      },
      list: function (artistId) {
        return email_lists.index({
          id: artistId,
        });
      },
    };
  });

  angular
    .module("mau.services")
    .factory("emailListsService", emailListsService);
}.call(this));
