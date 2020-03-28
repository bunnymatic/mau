import angular from "angular";
import ngInject from "@js/ng-inject";

const applicationEventsService = ngInject(function ($resource) {
  const applicationEvents = $resource(
    "/admin/application_events.json",
    {},
    {
      index: {
        method: "GET",
        cache: true,
        isArray: true,
        transformResponse: function (data, _header) {
          var ref;
          return (ref = angular.fromJson(data)) != null
            ? ref.application_events
            : void 0;
        },
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
  .factory("ApplicationEventsService", applicationEventsService);
