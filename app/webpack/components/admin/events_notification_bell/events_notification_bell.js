import some from "lodash/some";
import ngInject from "@js/ng-inject";

const controller = ngInject(function (
  $scope,
  $attrs,
  EmailChangedEventsService,
  moment
) {
  const since = moment().subtract(7, "days");
  EmailChangedEventsService.list({
    since: since.format(),
  });
  return EmailChangedEventsService.list({
    since: since.format(),
  }).then(function (data) {
    return ($scope.hasNotifications = some(data));
  });
});

const eventsNotificationBell = ngInject(function () {
  return {
    restrict: "E",
    templateUrl: "admin/events_notification_bell/index.html",
    controller: controller,
    scope: {},
  };
});

angular
  .module("mau.directives")
  .directive("eventsNotificationBell", eventsNotificationBell);
