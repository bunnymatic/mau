import angular from "angular";
import ngInject from "@js/ng-inject";

const emailsService = ngInject(function ($resource) {
  return $resource(
    "/admin/email_lists/:email_list_id/emails/:id",
    {
      id: "@id",
      email_list_id: "@email_list_id",
    },
    {
      query: {
        isArray: true,
        method: "GET",
        cache: false,
        responseType: "json",
        transformResponse: function (data, _header) {
          return angular.fromJson(data).emails || [];
        },
      },
      get: {
        isArray: false,
        method: "GET",
        cache: true,
        responseType: "json",
        transformResponse: function (data, _header) {
          var ref;
          return (ref = angular.fromJson(data)) != null ? ref.email : void 0;
        },
      },
      save: {
        method: "POST",
        responseType: "json",
      },
    }
  );
});

angular.module("mau.services").factory("emailsService", emailsService);
