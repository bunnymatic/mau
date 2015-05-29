emailListsService = ngInject ($resource) ->

  email_lists = $resource(
    '/admin/email_lists/:email_list_id/emails/:id.json'
    {}
    {
      get:
        method: 'GET'
        cache: true
        transformResponse: (data, header) ->
          angular.fromJson(data)?.email_lists
    }
  )
  get:(id) ->
    email_lists.get({id: id})

  list:(artistId) ->
    email_lists.index({id: artistId})

angular.module('mau.services').factory('emailListsService', emailListsService)
