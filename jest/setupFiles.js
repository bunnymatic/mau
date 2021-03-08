/* eslint-disable */
/* import sorting blows this test setup */
import angular from "angular";
import jQuery from "jquery";
import { DateTime } from "luxon";

import "angular-resource";
import "angular-sanitize";
import "ng-dialog/js/ngDialog";

/* eslint-enable */

angular.module("mau.services", ["ngResource"]);
angular.module("mau.directives", ["ngDialog"]);
angular.module("mau.models", []);

jest.dontMock("jquery");

jQuery.fx.off = true;

import "@testing-library/jest-dom";

const oldWindowLocation = window.location;

beforeAll(() => {
  delete window.location;

  window.location = Object.defineProperties(
    {},
    {
      ...Object.getOwnPropertyDescriptors(oldWindowLocation),
      assign: {
        configurable: true,
        value: jest.fn(),
      },
    }
  );
});
afterAll(() => {
  // restore `window.location` to the original `jsdom`
  // `Location` object
  window.location = oldWindowLocation;
});

DateTime.local().setZone("America/Los_Angeles");
