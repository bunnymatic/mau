emailsService = ngInject ($resource) ->

  $resource(
    '/admin/email_lists/:email_list_id/emails/:id'
    { id: '@id', email_list_id: '@email_list_id' }
    {
      query:
        isArray: true
        method: 'GET'
        cache: false
        responseType: 'json'
        transformResponse: (data, header) ->
          d = angular.fromJson(data)
          d? && _.pluck d, 'email'
      get:
        isArray: false
        method: 'GET'
        cache: true
        responseType: 'json'
        transformResponse: (data, header) ->
          angular.fromJson(data)?.email
      save:
        method: 'POST'
        responseType: 'json'
    }
  )

angular.module('mau.services').factory('emailsService', emailsService)