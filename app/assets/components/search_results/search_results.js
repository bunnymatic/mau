// Generated by CoffeeScript 1.12.7
(function() {
  var controller, searchResults;

  controller = ngInject(function($scope, $attrs, $element, searchService, SearchHit) {
    var startSpinner, stopSpinner;
    this.search_spinner = null;
    startSpinner = function() {
      if (!this.search_spinner) {
        this.search_spinner = new MAU.Spinner();
      }
      return this.search_spinner.spin();
    };
    stopSpinner = function() {
      var ref;
      return (ref = this.search_spinner) != null ? ref.stop() : void 0;
    };
    $scope.submitQuery = function() {
      return $scope.search($scope.queryString);
    };
    return $scope.search = function(query, pageSize, page) {
      var error, success;
      startSpinner();
      success = function(data) {
        $scope.hits = _.map(_.compact(data), function(datum) {
          return new SearchHit(datum);
        });
        return stopSpinner();
      };
      error = function(data) {
        return stopSpinner();
      };
      pageSize || (pageSize = 20);
      page || (page = 0);
      return searchService.query({
        query: query,
        size: pageSize,
        page: page,
        success: success,
        error: error
      });
    };
  });

  searchResults = ngInject(function() {
    return {
      restrict: 'E',
      controller: controller,
      templateUrl: 'search_results/index.html',
      link: function($scope, el, attrs) {
        var $form, path, ref;
        $form = $(el).find("form");
        path = new MAU.QueryStringParser(location.href);
        if (path) {
          $scope.queryString = (((ref = path.query_params) != null ? ref.q : void 0) || '').replace(/\+/, " ");
        }
        $scope.$watch("queryString", MAU.Utils.debounce($scope.submitQuery, 350, false));
        $(el).find("input").focus();
        return $form.on('submit', function(ev) {
          ev.preventDefault();
          $scope.search($scope.queryString);
          return false;
        });
      }
    };
  });

  angular.module('mau.directives').directive('searchResults', searchResults);

}).call(this);