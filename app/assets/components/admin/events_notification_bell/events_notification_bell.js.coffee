controller = ngInject ($scope, $attrs, EmailChangedEventsService, moment) ->
  since = moment().subtract(7, 'days');
  EmailChangedEventsService.list({since: since.format()}).then (data) ->
    $scope.hasNotifications = _.any(data)

eventsNotificationBell = ngInject () ->
  restrict: 'E'
  templateUrl: 'admin/events_notification_bell/index.html'
  controller: controller
  scope: {}

angular.module('mau.directives').directive('eventsNotificationBell', eventsNotificationBell)
