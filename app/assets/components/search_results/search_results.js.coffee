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
    $form.on 'submit', (ev) ->
      ev.preventDefault()
      query = $form.find("#search_query").val()
      $scope.search(query)
      false
      

angular.module('mau.directives').directive('searchResults', searchResults)
