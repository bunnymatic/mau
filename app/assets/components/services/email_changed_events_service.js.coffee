emailChangedEventsService = ngInject ($q, ApplicationEventsService) ->

  filterByChangedEmail = (data) ->
    _.find data, (event) ->
      /changed their email/.test(event.message)

  list: (params) ->
    events = ApplicationEventsService.list(params)
    events.$promise?.then (data) ->
      defer = $q.defer();
      defer.resolve( filterByChangedEmail( data ) )
      defer.promise;

angular.module('mau.services').factory('EmailChangedEventsService', emailChangedEventsService)
