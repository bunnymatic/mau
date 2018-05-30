// Generated by CoffeeScript 1.12.7
(function() {
  var controller, eventsNotificationBell;

  controller = ngInject(function(
    $scope,
    $attrs,
    EmailChangedEventsService,
    moment
  ) {
    var since, x;
    since = moment().subtract(7, "days");
    x = EmailChangedEventsService.list({
      since: since.format()
    });
    return EmailChangedEventsService.list({
      since: since.format()
    }).then(function(data) {
      data;
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
