import ngInject from "@angularjs/ng-inject";
import { responseTransformer } from "@js/mau_ajax";
import angular from "angular";

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
        transformResponse: responseTransformer("emails", []),
      },
      get: {
        isArray: false,
        method: "GET",
        cache: true,
        responseType: "json",
        transformResponse: responseTransformer("email"),
      },
      save: {
        method: "POST",
        responseType: "json",
      },
    }
  );
});

angular.module("mau.services").factory("emailsService", emailsService);
