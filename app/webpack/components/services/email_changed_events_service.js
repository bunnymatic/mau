import angular from "angular";
import ngInject from "@js/ng-inject";

(function () {
  var emailChangedEventsService;

  emailChangedEventsService = ngInject(function ($q, ApplicationEventsService) {
    var filterByChangedEmail;
    filterByChangedEmail = function (data) {
      return _.find(data, function (event) {
        return /updated.*email/.test(event.message);
      });
    };
    return {
      list: function (params) {
        var events, ref;
        events = ApplicationEventsService.list(params);
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
}.call(this));
