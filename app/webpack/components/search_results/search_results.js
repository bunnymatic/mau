import { debounce } from "@js/mau/utils";
import Spinner from "@js/mau/mau_spinner";
import QueryStringParser from "@js/mau/query_string_parser";
import angular from "angular";
import ngInject from "@js/ng-inject";
import template from "./index.html";

const controller = ngInject(function (
  $scope,
  $attrs,
  $element,
  searchService,
  SearchHit
) {
  this.search_spinner = null;

  const startSpinner = function () {
    if (!this.search_spinner) {
      this.search_spinner = new Spinner();
    }
    return this.search_spinner.spin();
  }.bind(this);

  const stopSpinner = function () {
    var ref;
    return (ref = this.search_spinner) != null ? ref.stop() : void 0;
  }.bind(this);

  $scope.submitQuery = function () {
    return $scope.search($scope.queryString);
  };
  $scope.search = function (query, pageSize, page) {
    startSpinner();

    const success = (data) => {
      $scope.hits = data
        .filter((x) => !!x)
        .map((datum) => new SearchHit(datum));
      stopSpinner();
    };

    const error = (_data) => stopSpinner();

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

const searchResults = ngInject(function () {
  return {
    restrict: "E",
    controller: controller,
    template: template,
    link: function ($scope, $el, _attrs) {
      let ref;
      const $form = $el.find("form");
      const path = new QueryStringParser(location.href);
      if (path) {
        $scope.queryString = (
          ((ref = path.query_params) != null ? ref.q : void 0) || ""
        ).replace(/\+/, " ");
      }
      $scope.$watch("queryString", debounce($scope.submitQuery, 350, false));
      $el.find("input")[0].focus();
      $form.bind("submit", function (ev) {
        ev.preventDefault();
        $scope.search($scope.queryString);
        return false;
      });
    },
  };
});

angular.module("mau.directives").directive("searchResults", searchResults);
