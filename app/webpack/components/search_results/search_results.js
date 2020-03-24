import { debounce } from "@js/mau/utils";
import Spinner from "@js/mau/mau_spinner";
import QueryStringParser from "@js/mau/query_string_parser";
import angular from "angular";
import ngInject from "@js/ng-inject";

(function () {
  var controller, searchResults;

  controller = ngInject(function (
    $scope,
    $attrs,
    $element,
    searchService,
    SearchHit
  ) {
    var startSpinner, stopSpinner;
    this.search_spinner = null;
    startSpinner = function () {
      if (!this.search_spinner) {
        this.search_spinner = new Spinner();
      }
      return this.search_spinner.spin();
    }.bind(this);
    stopSpinner = function () {
      var ref;
      return (ref = this.search_spinner) != null ? ref.stop() : void 0;
    }.bind(this);
    $scope.submitQuery = function () {
      return $scope.search($scope.queryString);
    };
    $scope.search = function (query, pageSize, page) {
      var error, success;
      startSpinner();
      success = function (data) {
        $scope.hits = _.map(_.compact(data), function (datum) {
          return new SearchHit(datum);
        });
        return stopSpinner();
      };
      error = function (_data) {
        return stopSpinner();
      };
      pageSize || (pageSize = 20);
      page || (page = 0);
      return searchService.query({
        query: query,
        size: pageSize,
        page: page,
        success: success,
        error: error,
      });
    };
  });

  searchResults = ngInject(function () {
    return {
      restrict: "E",
      controller: controller,
      templateUrl: "search_results/index.html",
      link: function ($scope, el, _attrs) {
        var $form, path, ref;
        $form = $(el).find("form");
        path = new QueryStringParser(location.href);
        if (path) {
          $scope.queryString = (
            ((ref = path.query_params) != null ? ref.q : void 0) || ""
          ).replace(/\+/, " ");
        }
        $scope.$watch("queryString", debounce($scope.submitQuery, 350, false));
        $(el).find("input").focus();
        return $form.on("submit", function (ev) {
          ev.preventDefault();
          $scope.search($scope.queryString);
          return false;
        });
      },
    };
  });

  angular.module("mau.directives").directive("searchResults", searchResults);
}.call(this));
