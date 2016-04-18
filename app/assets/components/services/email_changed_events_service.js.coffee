emailChangedEventsService = ngInject ($q, ApplicationEventsService) ->

  filterByChangedEmail = (data) ->
    _.find data, (event) ->
      /changed their email/.test(event.message)

  list: (params) ->
    events = ApplicationEventsService.list(params)
    events.$promise?.then (data) ->
      $q (resolve, reject) ->
        resolve( filterByChangedEmail )

angular.module('mau.services').factory('EmailChangedEventsService', emailChangedEventsService)
