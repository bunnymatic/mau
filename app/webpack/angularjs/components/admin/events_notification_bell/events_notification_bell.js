import ngInject from "@angularjs/ng-inject";
import some from "lodash/some";

import template from "./index.html";

const controller = ngInject(function (
  $scope,
  $attrs,
  EmailChangedEventsService,
  moment
) {
  const since = moment().subtract(7, "days");
  EmailChangedEventsService.list({
    since: since.format(),
  }).then(function (data) {
    return ($scope.hasNotifications = some(data));
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
