import angular from "angular";
import ngInject from "@js/ng-inject";

(function () {
  var directive;

  directive = ngInject(function () {
    var compile;
    compile = function (el, attrs) {
      var delim, delimHtml, html;
      delim = attrs.repeaterDelimiter || ",";
      delimHtml = "<span ng-show=' ! $last '>" + delim + "</span>";
      html = el.html().replace(/(\s*$)/i, function (whitespace) {
        return delimHtml + whitespace;
      });
      return el.html(html);
    };
    return {
      compile: compile,
      priority: 1001,
      restrict: "A",
    };
  });

  angular.module("mau.directives").directive("repeaterDelimiter", directive);
}.call(this));
