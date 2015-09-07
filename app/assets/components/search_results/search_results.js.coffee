controller = ngInject ($scope, $attrs, $element, searchService, SearchHit) ->
  $scope.search = (query, pageSize, page) ->
    success = (data) ->
      $scope.hits = _.map data, (datum) -> new SearchHit(datum)
    error = (data) ->
      console.log('results', data)
    pageSize ||= 10
    page ||= 0
    searchService.query({query: query, size: pageSize, page: page, success: success, error: error})

searchResults = ngInject () ->
  restrict: 'E'
  controller: controller
  templateUrl: 'search_results/index.html'
  link: ($scope, el, attrs) ->
    $form = $(el).find("form")
    path = new MAU.QueryStringParser(location.href)
    incomingQuery = null
    if path
      incomingQuery = path.query_params?.q
    if incomingQuery
      $form.find("#search_query").val(incomingQuery)
      $scope.search(incomingQuery)
    $form.on 'submit', (ev) ->
      ev.preventDefault()
      query = $form.find("#search_query").val()
      $scope.search(query)
      false



angular.module('mau.directives').directive('searchResults', searchResults)
