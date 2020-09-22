import ngInject from "@angularjs/ng-inject";
import { some } from "@js/app/helpers";
import { DateTime } from "luxon";

import template from "./index.html";

const controller = ngInject(function (
  $scope,
  $attrs,
  EmailChangedEventsService
) {
  const since = DateTime.local().minus({ days: 7 });
  EmailChangedEventsService.list({
    since: since.format(),
  })
    .then(function (data) {
      $scope.hasNotifications = some(data);
    })
    .catch(function (e) {
      console.error(e);
    });
});

const eventsNotificationBell = ngInject(function () {
  return {
    restrict: "E",
    template: template,
    controller: controller,
    scope: {},
  };
});

angular
  .module("mau.directives")
  .directive("eventsNotificationBell", eventsNotificationBell);
