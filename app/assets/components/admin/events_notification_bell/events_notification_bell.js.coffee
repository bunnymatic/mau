controller = ngInject ($scope, $attrs, EmailChangedEventsService, moment) ->
  since = moment().subtract(7, 'days');
  x = EmailChangedEventsService.list({since: since.format()})
  EmailChangedEventsService.list({since: since.format()}).then (data) ->
    data
    $scope.hasNotifications = _.some(data)

eventsNotificationBell = ngInject () ->
  restrict: 'E'
  templateUrl: 'admin/events_notification_bell/index.html'
  controller: controller
  scope: {}

angular.module('mau.directives').directive('eventsNotificationBell', eventsNotificationBell)
