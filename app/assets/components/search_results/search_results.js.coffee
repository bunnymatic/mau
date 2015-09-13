controller = ngInject ($scope, $attrs, $element, searchService, SearchHit) ->

  @search_spinner = null

  startSpinner = ->
    @search_spinner = new MAU.Spinner() unless @search_spinner
    @search_spinner.spin()
  stopSpinner = ->
    @search_spinner?.stop()

  $scope.submitQuery = () ->
    $scope.search($scope.queryString)

  $scope.search = (query, pageSize, page) ->
    startSpinner()
    success = (data) ->
      $scope.hits = _.map data, (datum) -> new SearchHit(datum)
      stopSpinner()
    error = (data) ->
      stopSpinner()
    pageSize ||= 20
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
      $scope.queryString = path.query_params?.q
    $scope.$watch("queryString", MAU.Utils.debounce($scope.submitQuery, 150, false))
    $form.on 'submit', (ev) ->
      ev.preventDefault()
      $scope.search(query)
      false



angular.module('mau.directives').directive('searchResults', searchResults)
