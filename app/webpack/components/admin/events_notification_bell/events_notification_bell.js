import angular from "angular";
import ngInject from "@js/ng-inject";

(function() {
  var controller, eventsNotificationBell;

  controller = ngInject(function(
    $scope,
    $attrs,
    EmailChangedEventsService,
    moment
  ) {
    var since;
    since = moment().subtract(7, "days");
    EmailChangedEventsService.list({
      since: since.format()
    });
    return EmailChangedEventsService.list({
      since: since.format()
    }).then(function(data) {
      return ($scope.hasNotifications = _.some(data));
    });
  });

  eventsNotificationBell = ngInject(function() {
    return {
      restrict: "E",
      templateUrl: "admin/events_notification_bell/index.html",
      controller: controller,
      scope: {}
    };
  });

  angular
    .module("mau.directives")
    .directive("eventsNotificationBell", eventsNotificationBell);
}.call(this));
