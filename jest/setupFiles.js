import jQuery from "jquery";
import angular from "angular";
import "angular-resource";
import "angular-sanitize";
import "ng-dialog/js/ngDialog";
import "ng-device-detector";

angular.module("mau.services", ["ngResource", "ng.deviceDetector"]);
angular.module("mau.directives", ["ngDialog"]);
angular.module("mau.models", []);

jest.dontMock("jquery");

jQuery.fx.off = true;
