import ngInject from "@angularjs/ng-inject";
import angular from "angular";

const emailChangedEventsService = ngInject(function (
  $q,
  applicationEventsService
) {
  const filterByChangedEmail = (data) => {
    return data.filter(
      (data) =>
        data.user_changed_event &&
        /update.*email/.test(data.user_changed_event.message)
    );
  };
  return {
    list: function (params) {
      const events = applicationEventsService.list(params);
      return events.$promise.then(function (data) {
        const defer = $q.defer();
        const filtered = filterByChangedEmail(data);
        defer.resolve(filtered);
        return defer.promise;
      });
    },
  };
});

angular
  .module("mau.services")
  .factory("EmailChangedEventsService", emailChangedEventsService);
