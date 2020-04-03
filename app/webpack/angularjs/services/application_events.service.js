import angular from "angular";
import ngInject from "@angularjs/ng-inject";
import { responseTransformer } from "@js/mau_ajax";

const applicationEventsService = ngInject(function ($resource) {
  const applicationEvents = $resource(
    "/admin/application_events.json",
    {},
    {
      index: {
        method: "GET",
        cache: true,
        isArray: true,
        transformResponse: responseTransformer("application_events", []),
      },
    }
  );
  return {
    list: function (params) {
      const args = {
        "query[since]": params.since,
      };
      return applicationEvents.index(args);
    },
  };
});

angular
  .module("mau.services")
  .factory("applicationEventsService", applicationEventsService);
