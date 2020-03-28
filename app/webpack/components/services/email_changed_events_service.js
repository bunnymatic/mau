import angular from "angular";
import ngInject from "@js/ng-inject";

const emailChangedEventsService = ngInject(function (
  $q,
  ApplicationEventsService
) {
  const filterByChangedEmail = (data) =>
    data.find((event) => /updated.*email/.test(event.message));
  return {
    list: function (params) {
      let ref;
      const events = ApplicationEventsService.list(params);
      return (ref = events.$promise) != null
        ? ref.then(function (data) {
            var defer;
            defer = $q.defer();
            defer.resolve(filterByChangedEmail(data));
            return defer.promise;
          })
        : void 0;
    },
  };
});

angular
  .module("mau.services")
  .factory("EmailChangedEventsService", emailChangedEventsService);
