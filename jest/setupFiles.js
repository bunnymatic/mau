/* eslint-disable */
/* import sorting blows this test setup */
import angular from "angular";
import jQuery from "jquery";

import "angular-resource";
import "angular-sanitize";
import "ng-dialog/js/ngDialog";
/* eslint-enable */

angular.module("mau.services", ["ngResource"]);
angular.module("mau.directives", ["ngDialog"]);
angular.module("mau.models", []);

jest.dontMock("jquery");

jQuery.fx.off = true;
