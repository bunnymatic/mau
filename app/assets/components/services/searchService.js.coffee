searchService = ngInject ($http) ->

  # expects arguments
  # query, pageSize, page, success, error
  # as a hash
  query: (searchParams) ->
    success = searchParams.success
    error = searchParams.error
    unless searchParams.query
      return success([])
    searchParams.q = searchParams.query
    $http.post('/search.json', searchParams).success((data) ->
      success(data.search)
    ).error((data) ->
      error(data.search)
    )

angular.module('mau.services').factory('searchService', searchService)
