searchService = ngInject ($http) ->

  # expects arguments
  # query, pageSize, page, success, error
  # as a hash
  query: (searchParams) ->
    console.log "QUERY", searchParams
    success = searchParams.success
    error = searchParams.error
    return unless searchParams.query
    searchParams.q = searchParams.query
    $http.post('/search/search.json', searchParams).success((data) ->
      success(data.search)
    ).error((data) ->
      error(data.search)
    )

angular.module('mau.services').factory('searchService', searchService)
