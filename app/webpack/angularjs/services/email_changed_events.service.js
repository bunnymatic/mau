import angular from "angular";
import ngInject from "@angularjs/ng-inject";

const emailChangedEventsService = ngInject(function (
  $q,
  applicationEventsService
) {
  const filterByChangedEmail = (data) =>
    data.find((event) => /update.*email/.test(event.message));
  return {
    list: function (params) {
      const events = applicationEventsService.list(params);
      return events.$promise.then(function (data) {
        const defer = $q.defer();
        defer.resolve(filterByChangedEmail(data));
        return defer.promise;
      });
    },
  };
});

angular
  .module("mau.services")
  .factory("EmailChangedEventsService", emailChangedEventsService);
