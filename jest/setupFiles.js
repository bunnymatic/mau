import jQuery from "jquery";
import angular from "angular";
import "angular-resource";
import "angular-sanitize";

angular.module("mau.services", ["ngResource"]);
angular.module("mau.directives", []);
angular.module("mau.models", []);

jest.dontMock("jquery");

jQuery.fx.off = true;
