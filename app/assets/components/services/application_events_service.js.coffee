applicationEventsService = ngInject ($resource) ->

  applicationEvents = $resource(
    '/admin/application_events.json'
    { }
    {
      index:
        method: 'GET'
        cache: true
        isArray: true
        transformResponse: (data, header) ->
          angular.fromJson(data)?.application_events
    }
  )

  list: (params) ->
    args = _.extend({ limit: 10 }, _.pick(params, 'since'))
    applicationEvents.index(args)

angular.module('mau.services').factory('ApplicationEventsService', applicationEventsService)
