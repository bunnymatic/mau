import ngInject from "@angularjs/ng-inject";
import QueryStringParser from "@js/app/query_string_parser";
import Spinner from "@js/app/spinner";
import { debounce } from "@js/app/utils";
import angular from "angular";

import template from "./index.html";

const controller = ngInject(function (
  $scope,
  $attrs,
  $element,
  searchService,
  SearchHit
) {
  this.searchSpinner = null;

  const startSpinner = () => {
    if (!this.searchSpinner) {
      this.searchSpinner = new Spinner();
    }
    return this.searchSpinner.spin();
  };

  const stopSpinner = () => this.searchSpinner && this.searchSpinner.stop();

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
          ((ref = path.queryParams) != null ? ref.q : void 0) || ""
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
